CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Booking RESULT result.
    METHODS calculate_total_price FOR DETERMINE ON MODIFY
      IMPORTING keys FOR booking~calculate_total_price.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR booking RESULT result.

    METHODS apply_discount FOR MODIFY
      IMPORTING keys FOR ACTION booking~apply_discount RESULT result.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD calculate_Total_Price.


*    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
*    ENTITY Booking
*    FIELDS ( TravelUUID )
    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
        ENTITY Booking
        BY \_Travel
        FIELDS ( TravelUUID )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travels).
    IF lt_travels IS INITIAL.

        DATA(lv_booking_uuid) = VALUE #( keys[ 1 ]-BookingUuid OPTIONAL ).
        SELECT SINGLE TravelUUID
            FROM zrk_sde_d_book
            WHERE BookingUuid = @lv_booking_uuid
            INTO @DATA(lv_travel_uuid).
            IF sy-subrc EQ 0.
                APPEND VALUE #( %tky-%is_draft = if_abap_behv=>mk-on
                                traveluuid = lv_travel_uuid ) TO lt_travels.
            ENDIF.

    ENDIF.

    "update involved instances
    MODIFY ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Travel
        EXECUTE recalctotalprice
        FROM VALUE #( FOR <fs_key> IN lt_travels ( %tky = <fs_key>-%tky ) ).


  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD Apply_Discount.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
      DATA(lv_disc_percent) = <fs_key>-%param-Discount_percent.
    ENDLOOP.

    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
        ENTITY Booking
        FIELDS ( FlightPrice )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_bookings).

    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).
      <fs_booking>-FlightPrice = <fs_booking>-FlightPrice * ( 100 - lv_disc_percent ) / 100.
    ENDLOOP.

    "update involved instances
    MODIFY ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Booking
        UPDATE FIELDS ( FlightPrice )
        WITH VALUE #( FOR <fs_book> IN lt_bookings  (
                           %tky      = <fs_book>-%tky
                           FlightPrice  = <fs_book>-FlightPrice  ) ).

    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
        ENTITY Booking
        FIELDS ( FlightPrice )
         WITH CORRESPONDING #( keys )
         RESULT DATA(lt_bookings_upd).

    RESUlT = VALUE #( FOR <fs_res> IN lt_bookings_upd ( %tky = <fs_res>-%tky %param = <fs_res> ) ) .

  ENDMETHOD.

ENDCLASS.

CLASS lhc_travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR Travel
        RESULT result,
      Set_Travel_no FOR DETERMINE ON SAVE
        IMPORTING keys FOR Travel~Set_Travel_no,
      Valid_Dates FOR VALIDATE ON SAVE
        IMPORTING keys FOR Travel~Valid_Dates,
      Calculate_Total_price FOR DETERMINE ON MODIFY
        IMPORTING keys FOR Travel~Calculate_Total_price,
      ReCalcTotalPrice FOR MODIFY
        IMPORTING keys FOR ACTION Travel~ReCalcTotalPrice.
ENDCLASS.

CLASS lhc_travel IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD Set_Travel_no.


    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
    ENTITY Travel
      FIELDS ( TravelID )
      WITH CORRESPONDING #( keys )
    RESULT DATA(travels).

    DELETE travels WHERE TravelID IS NOT INITIAL.
    CHECK travels IS NOT INITIAL.

    "Get max travelID
    SELECT SINGLE FROM zrk_sde_a_travel FIELDS MAX( travel_id ) INTO @DATA(max_travelid).
    IF max_travelid = 0.
      max_travelid = 90000000.
    ENDIF.

    "update involved instances
    MODIFY ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( TravelID )
        WITH VALUE #( FOR travel IN travels INDEX INTO i (
                           %tky      = travel-%tky
                           TravelID  = max_travelid + i ) ).

  ENDMETHOD.

  METHOD Valid_Dates.

    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
        ENTITY Travel
    FIELDS ( BeginDate EndDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(travel).

      APPEND VALUE #(  %tky               = travel-%tky
                     %state_area        = 'VALIDATE_DATES' ) TO reported-travel.

      IF travel-BeginDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_begin_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
      IF travel-EndDate IS INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg                = NEW /dmo/cm_flight_messages(
                                                                textid   = /dmo/cm_flight_messages=>enter_end_date
                                                                severity = if_abap_behv_message=>severity-error )
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
      IF travel-EndDate < travel-BeginDate AND travel-BeginDate IS NOT INITIAL
                                           AND travel-EndDate IS NOT INITIAL.
        APPEND VALUE #( %tky = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                        %msg               = NEW /dmo/cm_flight_messages(
                                                                textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                                                begin_date = travel-BeginDate
                                                                end_date   = travel-EndDate
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on
                        %element-EndDate   = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
      IF travel-BeginDate < cl_abap_context_info=>get_system_date( ) AND travel-BeginDate IS NOT INITIAL.
        APPEND VALUE #( %tky               = travel-%tky ) TO failed-travel.

        APPEND VALUE #( %tky               = travel-%tky
                        %state_area        = 'VALIDATE_DATES'
                         %msg              = NEW /dmo/cm_flight_messages(
                                                                begin_date = travel-BeginDate
                                                                textid     = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                                                severity   = if_abap_behv_message=>severity-error )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD Calculate_Total_price.


    "update involved instances
    MODIFY ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Travel
        EXECUTE recalctotalprice
        FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD ReCalcTotalPrice.

    READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Travel
        FIELDS ( BookingFee )
           WITH CORRESPONDING #( keys )
         RESULT DATA(lt_travels).


    LOOP AT lt_travels ASSIGNING FIELD-SYMBOL(<Fs_travel>).

      <Fs_travel>-TotalPrice = <Fs_travel>-BookingFee.

      READ ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
          ENTITY Travel
          BY \_Booking
          FIELDS ( FlightPrice )
           WITH VALUE #( ( %tky = <fs_travel>-%tky ) )
           RESULT DATA(lt_bookings).

      LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<fs_booking>).
        <Fs_travel>-TotalPrice = <Fs_travel>-TotalPrice + <fs_booking>-FlightPrice.
      ENDLOOP.

    ENDLOOP.

    "update involved instances
    MODIFY ENTITIES OF zrk_sde_i_travel IN LOCAL MODE
      ENTITY Travel
        UPDATE FIELDS ( TotalPrice )
        WITH VALUE #( FOR travel IN lt_travels  (
                           %tky      = travel-%tky
                           TotalPrice  = travel-TotalPrice ) ).

  ENDMETHOD.

ENDCLASS.
