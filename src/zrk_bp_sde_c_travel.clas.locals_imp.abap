CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS CopyTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~CopyTravel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD CopyTravel.


    DATA : lt_travel_copy TYPE TABLE FOR CREATE zrk_sde_c_travel\\Travel.

    " remove travel instances with initial %cid (i.e., not set by caller API)
    READ TABLE keys WITH KEY %cid = '' INTO DATA(key_with_inital_cid).
    ASSERT key_with_inital_cid IS INITIAL.

    " read the data from the travel instances to be copied
    READ ENTITIES OF zrk_sde_c_travel IN LOCAL MODE
      ENTITY travel
       ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_source)
    FAILED failed.


    LOOP AT lt_travel_source ASSIGNING FIELD-SYMBOL(<travel>).
      " fill in travel container for creating new travel instance
      APPEND VALUE #( %cid      = keys[ KEY entity %key = <travel>-%key ]-%cid
                      %is_draft = keys[ KEY entity %key = <travel>-%key ]-%param-%is_draft
                      %data     = CORRESPONDING #( <travel> EXCEPT TravelID )
                   )
        TO lt_travel_copy ASSIGNING FIELD-SYMBOL(<new_travel>).

      " adjust the copied travel instance data
      "" BeginDate must be on or after system date
      <new_travel>-BeginDate     = cl_abap_context_info=>get_system_date( ).
      "" EndDate must be after BeginDate
      <new_travel>-EndDate       = cl_abap_context_info=>get_system_date( ) + 30.
      "" OverallStatus of new instances must be set to open ('O')
      <new_travel>-OverallStatus = 'O'.
    ENDLOOP.

    " create new BO instance
    MODIFY ENTITIES OF zrk_sde_c_travel IN LOCAL MODE
      ENTITY travel
        CREATE FIELDS ( AgencyID CustomerID BeginDate EndDate BookingFee
                        TotalPrice CurrencyCode OverallStatus Description )
          WITH lt_travel_copy
      MAPPED DATA(mapped_create).

    " set the new BO instances
    mapped-travel   =  mapped_create-travel .

  ENDMETHOD.

ENDCLASS.
