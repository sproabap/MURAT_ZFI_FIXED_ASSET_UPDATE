@EndUserText.label: 'Abstract Entity for Excel Update Fixed Asset'
define root abstract entity ZA_FI_FIXED_ASSET_ABST

{
  @Semantics.largeObject.mimeType: 'MimeType'
  @Semantics.largeObject.fileName: 'FileName'
  @Semantics.largeObject.contentDispositionPreference: #INLINE
  @EndUserText.label: 'Select Excel file'
  StreamProperty : abap.rawstring(0);
  MimeType : abap.char(128);
  FileName : abap.char(128);  
    
}
