@EndUserText.label: 'Abst. Ent. for Excel Fixed Asset Stream'
define root abstract entity ZA_FI_FIXED_ASSET_STREAM
  
{
        // Dummy is a dummy field
@UI.hidden: true
dummy : abap_boolean;
     _StreamProperties : association [1] to ZA_FI_FIXED_ASSET_ABST on 1 = 1;
    
}
