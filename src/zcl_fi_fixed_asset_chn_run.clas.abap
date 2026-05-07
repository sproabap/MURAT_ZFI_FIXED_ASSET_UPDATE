CLASS zcl_fi_fixed_asset_chn_run DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_FIXED_ASSET_CHN_RUN IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    DATA(msg_id) = cl_system_uuid=>create_uuid_c36_static( ).



    DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).

    IF NOT lv_system_url  CS '-api'.
      REPLACE FIRST OCCURRENCE OF '.s4hana.cloud.sap'
              IN lv_system_url
              WITH '-api.s4hana.cloud.sap'.
    ENDIF.

    DATA(lv_url) = 'https://' && lv_system_url  && '/sap/bc/srt/scs_ext/sap/fixedassetchange?MessageId=' && msg_id.

    DATA: destination_soap TYPE REF TO IF_soap_DESTINATION.
    DATA: lv_timestamp TYPE timestampl.
    data ls_timevaluation TYPE ZTIME_BASED_VALUATION_FOR_CHAN.
    data ls_ledger TYPE zledger_information_for_change.


    TRY.
        "destination_soap = cl_soap_destination_provider=>create_by_url( i_url = CONV #( lv_url ) ).

               TRY.

           cl_soap_destination_provider=>create_by_comm_arrangement(
             EXPORTING
               comm_scenario  = 'ZCS_FI_FIXED_ASSET_COM_SCN'
               service_id     = 'ZOUT_FI_FIXED_ASSET_OUT_SERV_SPRX'
               comm_system_id = 'API_COM_SYSTEM'
             RECEIVING
               r_destination  = data(destination_proxy)
           ).
           CATCH cx_soap_destination_error into data(lo_error_Dest).
                DATA(lv_error_text) = lo_error_Dest->get_text( ).
           ENDTRY.


*
*        destination_proxy->set_basic_authentication(
*          i_user     = 'HML_CUSTOMIZING_DEV'
*          i_password = 'GVYkBfUkYl8+zYYkrjGWmHAfrXnebpDjLfDMJKwW'
*        ).



*        CATCH cx_soap_destination_error.
      CATCH cx_soap_destination_error INTO DATA(lo_url_error).
        "handle exception
    ENDTRY.

      TRY.

          TRY.
              DATA(proxy) = NEW zco_fixed_asset_change_bulk_re(

                    destination = destination_proxy


              ).

            CATCH cx_ai_system_fault INTO DATA(lo_new_error).
                DATA(lv_error_text2) = lo_new_error->get_text( ).
          ENDTRY.

          " fill request
          DATA(request) = VALUE zfixed_asset_change_bulk_requ1( ).

          DATA ls_fixed_asset_chn LIKE LINE OF request-fixed_asset_change_bulk_reques-fixed_asset_change_request.

          GET TIME STAMP FIELD lv_timestamp.




          request-fixed_asset_change_bulk_reques-message_header-creation_date_time = lv_timestamp.
          request-fixed_asset_change_bulk_reques-message_header-id-scheme_id = cl_system_uuid=>create_uuid_c32_static( ).
          request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id = cl_system_uuid=>create_uuid_c36_static( ).
          request-fixed_asset_change_bulk_reques-message_header-reference_uuid-scheme_id = request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id.
          "request-fixed_asset_change_bulk_reques-message_header-sender_business_system_id = 'API_COM_SYSTEM'.
          "request-fixed_asset_change_bulk_reques-message_header-recipient_business_system_id = 'API_COM_SYSTEM'.

          CLEAR ls_fixed_asset_chn.
          ls_fixed_asset_chn-message_header-uuid-scheme_id = cl_system_uuid=>create_uuid_c36_static( ).
          ls_fixed_asset_chn-message_header-creation_date_time = lv_timestamp.

          ls_fixed_asset_chn-fixed_asset-company_code =  '1000'.
          ls_fixed_asset_chn-fixed_asset-master_fixed_asset = '000030001015'.
          ls_fixed_asset_chn-fixed_asset-fixed_asset = '0000'.
          ls_fixed_asset_chn-fixed_asset-general-fixed_asset_description = 'burak_1_1'.
          ls_fixed_asset_chn-fixed_asset-general-asset_additional_description = 'burak2_1_!'.

*          ls_ledger-ledger = '0L'.
*          append ls_ledger to ls_fixed_asset_chn-fixed_asset-ledger_information.
*
*          ls_ledger-ledger = '2L'.
*          append ls_ledger to ls_fixed_asset_chn-fixed_asset-ledger_information.
*          "ls_fixed_asset_chn-fixed_asset-ledger_information

          ls_timevaluation-asset_depreciation_area = '01'.
          ls_timevaluation-depreciation_key = '0000'.
          ls_timevaluation-action_code = '02'.
          ls_timevaluation-validity_start_date = '19000101'.
          APPEND ls_timevaluation to ls_fixed_asset_chn-fixed_asset-time_based_valuation.

          ls_timevaluation-asset_depreciation_area = '16'.
          ls_timevaluation-depreciation_key = 'TR07'.
          ls_timevaluation-action_code = '02'.
          ls_timevaluation-validity_start_date = '19000101'.
          APPEND ls_timevaluation to ls_fixed_asset_chn-fixed_asset-time_based_valuation.

          APPEND ls_fixed_asset_chn TO request-fixed_asset_change_bulk_reques-fixed_asset_change_request.

*          CLEAR ls_fixed_asset_chn. "refresh ls_fixed_asset_chn.
*          ls_fixed_asset_chn-message_header-uuid-scheme_id = cl_system_uuid=>create_uuid_c36_static( ).
*          ls_fixed_asset_chn-message_header-creation_date_time = lv_timestamp.
*
*          ls_fixed_asset_chn-fixed_asset-company_code =  '1000'.
*          ls_fixed_asset_chn-fixed_asset-master_fixed_asset = '000030001016'.
*          ls_fixed_asset_chn-fixed_asset-fixed_asset = '0000'.
*          ls_fixed_asset_chn-fixed_asset-general-fixed_asset_description = '3test'.
*          ls_fixed_asset_chn-fixed_asset-general-asset_additional_description = '3test'.
*          APPEND ls_fixed_asset_chn TO request-fixed_asset_change_bulk_reques-fixed_asset_change_request.

          proxy->fixed_asset_change_bulk_reques(
            EXPORTING
              input = request
          ).

          COMMIT WORK.

          FREE proxy.



          " trigger async call
          "commit work.
        CATCH cx_ai_system_fault INTO DATA(lo_error).
          " handle error
        CATCH cx_root INTO DATA(lo_root).
      ENDTRY.


  ENDMETHOD.
ENDCLASS.
