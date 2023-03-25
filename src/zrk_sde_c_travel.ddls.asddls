@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZRK_SDE_I_TRAVEL'
define root view entity ZRK_SDE_C_TRAVEL
  provider contract transactional_query
  as projection on ZRK_SDE_I_TRAVEL
{
  key TravelUUID,
  TravelID,
  AgencyID,
  CustomerID,
  BeginDate,
  EndDate,
  BookingFee,
  TotalPrice,
  CurrencyCode,
  Description,
  OverallStatus,
  LocalLastChangedAt,
  
  _Booking : redirected to composition child zrk_sde_c_booking
  
}
