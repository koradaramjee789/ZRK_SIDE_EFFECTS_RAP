@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED Gen for travel'
define root view entity ZRK_SDE_I_TRAVEL
  as select from zrk_sde_a_travel as Travel
  
  composition [0..*] of zrk_sde_i_booking         as _Booking
  association [0..1] to /DMO/I_Agency            as _Agency        on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer      on $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Overall_Status_VH as _OverallStatus on $projection.OverallStatus = _OverallStatus.OverallStatus
  association [0..1] to I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
{
  key travel_uuid as TravelUUID,
  travel_id as TravelID,
    @Consumption.valueHelpDefinition: [{
      entity: {
          name: '/DMO/I_Agency',
          element: 'AgencyID'
      }
   }]
  agency_id as AgencyID,
    @Consumption.valueHelpDefinition: [{
      entity: {
          name: '/DMO/I_Customer',
          element: 'CustomerID'
      }
   }]
  customer_id as CustomerID,
  begin_date as BeginDate,
  end_date as EndDate,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  booking_fee as BookingFee,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  total_price as TotalPrice,
      @Consumption.valueHelpDefinition: [{
      entity: {
          name: 'I_Currency',
          element: 'Currency'
      }
   }]
  currency_code as CurrencyCode,
  description as Description,
  @UI:{ textArrangement: #TEXT_ONLY }
      @Consumption.valueHelpDefinition: [{
      entity: {
          name: '/DMO/I_Overall_Status_VH',
          element: 'OverallStatus'
      }
   }]
  overall_status as OverallStatus,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  
  _Booking,
  _Agency,
  _Customer,
  _Currency,
  _OverallStatus
  
}
