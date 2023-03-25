@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'zrk_sde_i_booking'
define view entity zrk_sde_i_booking as select from zrk_sde_a_book
association to parent ZRK_SDE_I_TRAVEL as _Travel
    on $projection.TravelUUID = _Travel.TravelUUID
{
    key booking_uuid as BookingUuid,
    parent_uuid as TravelUUID,
    booking_id as BookingId,
    booking_date as BookingDate,
    customer_id as CustomerId,
    carrier_id as CarrierId,
    connection_id as ConnectionId,
    flight_date as FlightDate,
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as BookingStatus,
    local_last_changed_at as LocalLastChangedAt,
    _Travel 
}
