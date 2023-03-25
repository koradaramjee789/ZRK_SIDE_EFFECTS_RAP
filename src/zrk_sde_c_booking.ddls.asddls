@EndUserText.label: 'ZRK_SDE_C_BOOKING'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZRK_SDE_C_BOOKING
  as projection on zrk_sde_i_booking
{
  key BookingUuid,
      TravelUUID,
      BookingId,
      BookingDate,
      CustomerId,
      CarrierId,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      @Consumption.valueHelpDefinition: [{
      entity: {
      name: 'I_Currency',
      element: 'Currency'
      }
      }]
      CurrencyCode,
      BookingStatus,
      LocalLastChangedAt,
      /* Associations */
      _Travel : redirected to parent ZRK_SDE_C_TRAVEL
}
