

CLASS lhc_zr_fi_fixed_asset DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PUBLIC SECTION.
    CLASS-DATA  file_content TYPE xstring.

  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrFiFixedAsset
        RESULT result,
      ExcelUpload FOR MODIFY
        IMPORTING keys FOR ACTION ZrFiFixedAsset~ExcelUpload.
ENDCLASS.

CLASS lhc_zr_fi_fixed_asset IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.
  METHOD ExcelUpload.

    DATA ls_fixed_asset TYPE zfi_fixed_asset.
    DATA lt_fixed_asset TYPE TABLE OF zfi_fixed_asset.

    TYPES : BEGIN OF ty_sheet_data,
              companycode               TYPE bukrs,
              masterfixedasset          TYPE anln1,
              fixedasset                TYPE anln2,
              ledger                    TYPE char2,
              fixedassetdescription     TYPE text50,
              costcenter                TYPE char10,
              profitcenter              TYPE char10,
              assetrealdepreciationarea TYPE numc2,
              depreciationkey           TYPE char4,
              plannedusefullifeinyears  TYPE numc3,
              depreciationstartdate     TYPE char10,
            END OF ty_sheet_data.

    TYPES : BEGIN OF ty_excel_data,
              companycode               TYPE text40,
              masterfixedasset          TYPE text40,
              fixedasset                TYPE text40,
              ledger                    TYPE text40,
              fixedassetdescription     TYPE text40,
              assetrealdepreciationarea TYPE text40,
              depreciationkey           TYPE text40,
              costcenter                TYPE text40,
              profitcenter              TYPE text40,
              plannedusefullifeinyears  TYPE text40,
              depreciationstartdate     TYPE text40,
            END OF ty_excel_data.

    TYPES : BEGIN OF ty_excel_col_data,
              companycode      TYPE text40,
              masterfixedasset TYPE text40,
              fixedasset       TYPE text40,
            END OF ty_excel_col_data.

    DATA lv_file_content   TYPE xstring.
    DATA lt_sheet_data     TYPE STANDARD TABLE OF ty_excel_data.
    DATA: lv_timestamp TYPE timestampl.
    DATA: destination_soap TYPE REF TO IF_soap_DESTINATION.
    DATA lt_fixed_Asset_excel TYPE TABLE OF ty_sheet_data.
    DATA ls_fixed_Asset_excel TYPE ty_sheet_data.
    DATA lt_fixed_Asset_col TYPE TABLE OF ty_excel_col_data.
    DATA ls_fixed_Asset_col TYPE ty_excel_col_data.
    DATA ls_timevaluation TYPE ztime_based_valuation_for_chan.
    "CLASS-DATA: destination_soap TYPE REF TO if_soap_destination.


*    DATA lt_listing_create TYPE TABLE FOR CREATE zr_odtest4_excel1.

    lv_file_content = VALUE #( keys[ 1 ]-%param-_streamproperties-StreamProperty OPTIONAL ).

    file_content = lv_file_content.

     APPEND VALUE #( %cid = keys[ 1 ]-%cid
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = 'Veriler sisteme aktarılacak. Sayfayı yenileyiniz.' )
          ) TO reported-zrfifixedasset.

    "DATA(lo_operation) = NEW zcl_fi_fixed_asset_bg( iv_content = lv_file_content ).

    " 3. Background Message Control (BGMC) servisini çağır
    " 'uncontrolled' olduğu için COMMIT gerektiren işlemler yapılabilir.

*    TRY.
*
*        "DATA background_process TYPE REF TO if_bgmc_process_single_op.
*        DATA(background_process) = cl_bgmc_process_factory=>get_default(  )->create(  ).
*        background_process->set_name( 'Fixed Asset Change BG' )->set_operation_tx_uncontrolled( lo_operation ).
*        background_process->save_for_execution(  ).
*      CATCH cx_bgmc INTO DATA(exception).
*        reported-zrfifixedasset = VALUE #( ( %cid = keys[ 1 ]-%cid
*                                            %msg                = new_message_with_text(
*                                                                      severity = if_abap_behv_message=>severity-error
*                                                                      text     = CONV #( exception->get_longtext( ) ) ) ) ).
*
*    ENDTRY.

**********************************************************************
*** JOB
**********************************************************************

*    DATA txt                TYPE string.
*    DATA tz                 TYPE timezone.
*
*    DATA dat                TYPE d.
*    DATA tim                TYPE t.
*    DATA template_name      TYPE cl_apj_rt_api=>ty_template_name.
*    DATA ls_start_info      TYPE cl_apj_rt_api=>ty_start_info.
*    DATA ls_scheduling_info TYPE cl_apj_rt_api=>ty_scheduling_info.
*    DATA jobname            TYPE cl_apj_rt_api=>ty_jobname.
*    DATA jobcount           TYPE cl_apj_rt_api=>ty_jobcount.
*    DATA status             TYPE cl_apj_rt_api=>ty_job_status.
*    DATA statustext         TYPE cl_apj_rt_api=>ty_job_status_text.
*    " TODO: variable is assigned but only used in commented-out code (ABAP cleaner)
**    DATA ls_job_exception   TYPE cl_apj_rt_api=>ty_job_exception.
*
*    DATA ls_end_info        TYPE cl_apj_rt_api=>ty_end_info.
*
*    template_name = 'ZFI_FIXED_ASSET_JOB_TEMP'.
*
*    dat = cl_abap_context_info=>get_system_date( ).
*    tim = cl_abap_context_info=>get_system_time( ) + 5.
*
*    tz = cl_abap_tstmp=>get_system_timezone( ).
*
*    CONVERT DATE dat TIME tim
*            INTO TIME STAMP DATA(ts) TIME ZONE tz.
*
*    ls_start_info-timestamp = ts.
*
*    ls_scheduling_info-periodic_value = 1.
*    ls_scheduling_info-test_mode      = abap_false.
*    ls_scheduling_info-timezone       = tz.
*
*    ls_end_info-type           = cl_apj_rt_api=>period_end_by_nr_of_executions.
*    ls_end_info-max_iterations = 2.
*
*    DATA lt_templ_param_tab  TYPE cl_apj_rt_api=>tt_templ_param_val_multistep.
*    DATA lt_simple_param_tab TYPE cl_apj_rt_api=>tt_job_param_val_simple.
*
*    TRY.
*        lt_templ_param_tab = cl_apj_rt_api=>get_template_param_values( iv_job_template_name = template_name ).
*      CATCH cx_apj_rt INTO DATA(exception).
*        txt = exception->get_longtext( ).
*    ENDTRY.
*    lt_simple_param_tab = CORRESPONDING #( lt_templ_param_tab ).
*
*    DATA wa_param TYPE cl_apj_rt_api=>ty_job_param_val_simple.
*    DATA wa_value TYPE cl_apj_rt_api=>ty_value_range.
*
*    READ TABLE lt_simple_param_tab INTO wa_param WITH KEY step_nr = 1
*                                                          name    = 'MV_FIXED_ASSET'.
*    IF sy-subrc = 0.
*      CLEAR wa_param-t_value.
*
*      wa_value-sign   = 'I'.
*      wa_value-option = 'EQ'.
*      wa_value-low    = lv_file_content(40).
*
*      APPEND wa_value TO wa_param-t_value.
*
*      MODIFY TABLE lt_simple_param_tab FROM wa_param.
*
*    ENDIF.
*
*    TRY.
*
*        cl_apj_rt_api=>schedule_job( EXPORTING
*                                       iv_job_template_name          = template_name
**                                       iv_job_text                   = job_text
*                                       iv_job_text                   = TEXT-001 " WBS Update
*                                       is_start_info                 = ls_start_info
*                                       is_scheduling_info            = ls_scheduling_info
*                                       is_end_info                   = ls_end_info
*                                       iv_jobname                    = jobname
*                                       iv_jobcount                   = jobcount
*                                       it_job_parameter_value_simple = lt_simple_param_tab
*
*                                     IMPORTING
*                                       ev_jobname                    = jobname
*                                       ev_jobcount                   = jobcount ).
*
*        CONCATENATE jobname jobcount INTO txt SEPARATED BY space.
*
*        cl_apj_rt_api=>get_job_status( EXPORTING
*                                         iv_jobname         = jobname
*                                         iv_jobcount        = jobcount
*                                       IMPORTING
*                                         ev_job_status      = status
*                                         ev_job_status_text = statustext ).
*        CONCATENATE 'status =' statustext INTO txt SEPARATED BY space.
*
*      CATCH cx_apj_rt INTO DATA(exc).
*        txt = exc->get_longtext( ).
*
*    ENDTRY.




**********************************************************************
*** JOB
**********************************************************************


*    APPEND VALUE #( %cid = keys[ 1 ]-%cid
*            %msg = new_message_with_text(
*                     severity = if_abap_behv_message=>severity-success
*                     text     = 'Excel verileri başarıyla sisteme aktarıldı.' )
*          ) TO reported-zrfifixedasset.
*    " Error handling in case file content is initial
*
*    DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( lv_file_content )->read_access( ).
*
*    DATA(lo_worksheet) = lo_document->get_workbook( )->worksheet->at_position( 1 ).
*
*    DATA(o_sel_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
*      )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )  " Start reading from Column A
*      )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'N' )   " End reading at Column N
*      )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )    " *** Start reading from ROW 2 to skip the header ***
*      )->get_pattern( ).
*
*    lo_worksheet->select( o_sel_pattern
*                                     )->row_stream(
*                                     )->operation->write_to( REF #( lt_sheet_data )
*                                     )->set_value_transformation(
*                                         xco_cp_xlsx_read_access=>value_transformation->string_value
*                                     )->execute( ).
*
**    DATA(msg_id) = cl_system_uuid=>create_uuid_c36_static( ).
**
**
**
**    DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
**
**    IF NOT lv_system_url  CS '-api'.
**      REPLACE FIRST OCCURRENCE OF '.s4hana.cloud.sap'
**              IN lv_system_url
**              WITH '-api.s4hana.cloud.sap'.
**    ENDIF.
**
**    DATA(lv_url) = 'https://' && lv_system_url  && '/sap/bc/srt/scs_ext/sap/fixedassetchange?MessageId=' && msg_id.
*
*
*    TRY.
*        "destination_soap = cl_soap_destination_provider=>create_by_url( i_url = CONV #( lv_url ) ).
*
*        TRY.
*
*            cl_soap_destination_provider=>create_by_comm_arrangement(
*              EXPORTING
*                comm_scenario  = 'ZCS_FI_FIXED_ASSET_COM_SCN'
*                service_id     = 'ZOUT_FI_FIXED_ASSET_OUT_SERV_SPRX'
*                comm_system_id = 'API_COM_SYSTEM'
*              RECEIVING
*                r_destination  = DATA(destination_proxy)
*            ).
*          CATCH cx_soap_destination_error INTO DATA(lo_error_Dest).
*            DATA(lv_error_text) = lo_error_Dest->get_text( ).
*        ENDTRY.
*
**        CATCH cx_soap_destination_error.
*      CATCH cx_soap_destination_error INTO DATA(lo_url_error).
*        "handle exception
*    ENDTRY.
*
*    TRY.
*        TRY.
*            DATA(proxy) = NEW zco_fixed_asset_change_bulk_re(
*
*                  destination = destination_proxy
*
*
*            ).
*
*          CATCH cx_ai_system_fault INTO DATA(lo_new_error).
*            DATA(lv_error_text2) = lo_new_error->get_text( ).
*        ENDTRY.
*
*        " fill request
*        DATA(request) = VALUE zfixed_asset_change_bulk_requ1( ).
*
*        DATA ls_fixed_asset_chn LIKE LINE OF request-fixed_asset_change_bulk_reques-fixed_asset_change_request.
*
*        GET TIME STAMP FIELD lv_timestamp.
*
*        LOOP AT lt_sheet_data INTO DATA(ls_sheet_data) WHERE companycode IS NOT INITIAL.
*
*          ls_fixed_Asset_excel-companycode = ls_sheet_data-companycode.
*          ls_fixed_Asset_excel-masterfixedasset = |{ ls_sheet_data-masterfixedasset ALPHA = IN }|.
*          ls_fixed_Asset_excel-fixedasset = |{ ls_sheet_data-fixedasset ALPHA = IN }|.
*          ls_fixed_Asset_excel-ledger = ls_sheet_data-ledger.
*          ls_fixed_Asset_excel-assetrealdepreciationarea = |{ ls_sheet_data-assetrealdepreciationarea ALPHA = IN }|.
*          ls_fixed_Asset_excel-fixedassetdescription = ls_sheet_data-fixedassetdescription.
*          ls_fixed_Asset_excel-depreciationkey = ls_sheet_data-depreciationkey.
*          IF ls_fixed_Asset_excel-depreciationkey = '0'.
*            ls_fixed_Asset_excel-depreciationkey = '0000'.
*          ENDIF.
*
*          APPEND ls_fixed_Asset_excel TO lt_fixed_asset_excel.
*
*          MOVE-CORRESPONDING ls_fixed_Asset_excel TO ls_fixed_Asset_col.
*          COLLECT ls_fixed_Asset_col INTO lt_fixed_Asset_col.
*
*        ENDLOOP..
*
*
*        request-fixed_asset_change_bulk_reques-message_header-creation_date_time = lv_timestamp.
*        request-fixed_asset_change_bulk_reques-message_header-id-scheme_id = cl_system_uuid=>create_uuid_c32_static( ).
*        request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id = cl_system_uuid=>create_uuid_c36_static( ).
*        request-fixed_asset_change_bulk_reques-message_header-reference_uuid-scheme_id = request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id.
*
*        LOOP AT lt_fixed_Asset_col INTO ls_fixed_Asset_col.
*
*          CLEAR ls_fixed_asset_chn.
*          ls_fixed_asset_chn-message_header-uuid-scheme_id = request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id.
*          ls_fixed_asset_chn-message_header-creation_date_time = lv_timestamp.
*
*          ls_fixed_asset_chn-fixed_asset-company_code =  ls_sheet_data-companycode.
*          ls_fixed_asset_chn-fixed_asset-master_fixed_asset = ls_sheet_data-masterfixedasset.
*          ls_fixed_asset_chn-fixed_asset-fixed_asset = ls_sheet_data-fixedasset.
*
*          LOOP AT lt_fixed_asset_excel INTO ls_fixed_Asset_excel WHERE companycode = ls_fixed_Asset_col-companycode
*                                                                   AND masterfixedasset = ls_fixed_Asset_col-masterfixedasset
*                                                                   AND fixedasset = ls_fixed_Asset_col-fixedasset .
*
*            ls_timevaluation-asset_depreciation_area = ls_fixed_Asset_excel-assetrealdepreciationarea.
*            ls_timevaluation-depreciation_key = ls_fixed_Asset_excel-depreciationkey.
*            ls_timevaluation-action_code = '02'.
*            ls_timevaluation-validity_start_date = '19000101'.
*            APPEND ls_timevaluation TO ls_fixed_asset_chn-fixed_asset-time_based_valuation.
*
*          ENDLOOP.
*
*          APPEND ls_fixed_asset_chn TO request-fixed_asset_change_bulk_reques-fixed_asset_change_request.
*
*        ENDLOOP.
*
*        proxy->fixed_asset_change_bulk_reques(
*           EXPORTING
*             input = request
*         ).




*        LOOP AT lt_sheet_data INTO ls_sheet_data WHERE companycode IS NOT INITIAL.
*
*
*
*
*
*
*
*          " COMMIT WORK.
*
*
*
*
*          " trigger async call
*          "commit work.
*
*
*        ENDLOOP.

*      CATCH cx_ai_system_fault INTO DATA(lo_error).
*        " handle error
*      CATCH cx_root INTO DATA(lo_root).
*    ENDTRY.

    "lt_listing_create = CORRESPONDING #( lt_sheet_data ).

  ENDMETHOD.

ENDCLASS.
CLASS lsc_zr_fi_fixed_asset DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zr_fi_fixed_asset IMPLEMENTATION.

  METHOD save_modified.

    IF lhc_zr_fi_fixed_asset=>file_content IS NOT INITIAL.

      DATA ls_fixed_asset TYPE zfi_fixed_asset.
      DATA lt_fixed_asset TYPE TABLE OF zfi_fixed_asset.

      TYPES : BEGIN OF ty_sheet_data,
                companycode               TYPE bukrs,
                masterfixedasset          TYPE anln1,
                fixedasset                TYPE anln2,
                ledger                    TYPE char2,
                fixedassetdescription     TYPE text50,
                costcenter                TYPE char10,
                profitcenter              TYPE char10,
                assetrealdepreciationarea TYPE numc2,
                depreciationkey           TYPE char4,
                plannedusefullifeinyears  TYPE numc3,
                depreciationstartdate     TYPE char10,
              END OF ty_sheet_data.

      TYPES : BEGIN OF ty_excel_data,
                companycode               TYPE text40,
                masterfixedasset          TYPE text40,
                fixedasset                TYPE text40,
                ledger                    TYPE text40,
                fixedassetdescription     TYPE text40,
                assetrealdepreciationarea TYPE text40,
                depreciationkey           TYPE text40,
                costcenter                TYPE text40,
                profitcenter              TYPE text40,
                plannedusefullifeinyears  TYPE text40,
                depreciationstartdate     TYPE text40,
              END OF ty_excel_data.

      TYPES : BEGIN OF ty_excel_col_data,
                companycode      TYPE text40,
                masterfixedasset TYPE text40,
                fixedasset       TYPE text40,
              END OF ty_excel_col_data.

      DATA lv_file_content   TYPE xstring.
      DATA lt_sheet_data     TYPE STANDARD TABLE OF ty_excel_data.
      DATA: lv_timestamp TYPE timestampl.
      DATA: destination_soap TYPE REF TO IF_soap_DESTINATION.
      DATA lt_fixed_Asset_excel TYPE TABLE OF ty_sheet_data.
      DATA ls_fixed_Asset_excel TYPE ty_sheet_data.
      DATA lt_fixed_Asset_col TYPE TABLE OF ty_excel_col_data.
      DATA ls_fixed_Asset_col TYPE ty_excel_col_data.
      DATA ls_timevaluation TYPE ztime_based_valuation_for_chan.
      data ls_log TYPE zfi_fixed_asset.


      " Error handling in case file content is initial

      DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( lhc_zr_fi_fixed_asset=>file_content )->read_access( ).

      DATA(lo_worksheet) = lo_document->get_workbook( )->worksheet->at_position( 1 ).

      DATA(o_sel_pattern) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
        )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )  " Start reading from Column A
        )->to_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'N' )   " End reading at Column N
        )->from_row( xco_cp_xlsx=>coordinate->for_numeric_value( 2 )    " *** Start reading from ROW 2 to skip the header ***
        )->get_pattern( ).

      lo_worksheet->select( o_sel_pattern
                                       )->row_stream(
                                       )->operation->write_to( REF #( lt_sheet_data )
                                       )->set_value_transformation(
                                           xco_cp_xlsx_read_access=>value_transformation->string_value
                                       )->execute( ).

*    DATA(msg_id) = cl_system_uuid=>create_uuid_c36_static( ).
*
*
*
*    DATA(lv_system_url) = cl_abap_context_info=>get_system_url( ).
*
*    IF NOT lv_system_url  CS '-api'.
*      REPLACE FIRST OCCURRENCE OF '.s4hana.cloud.sap'
*              IN lv_system_url
*              WITH '-api.s4hana.cloud.sap'.
*    ENDIF.
*
*    DATA(lv_url) = 'https://' && lv_system_url  && '/sap/bc/srt/scs_ext/sap/fixedassetchange?MessageId=' && msg_id.


      TRY.
          "destination_soap = cl_soap_destination_provider=>create_by_url( i_url = CONV #( lv_url ) ).

          TRY.

              cl_soap_destination_provider=>create_by_comm_arrangement(
                EXPORTING
                  comm_scenario  = 'ZCS_FI_FIXED_ASSET_COM_SCN'
                  service_id     = 'ZOUT_FI_FIXED_ASSET_OUT_SERV_SPRX'
                  comm_system_id = 'API_COM_SYSTEM'
                RECEIVING
                  r_destination  = DATA(destination_proxy)
              ).
            CATCH cx_soap_destination_error INTO DATA(lo_error_Dest).
              DATA(lv_error_text) = lo_error_Dest->get_text( ).
          ENDTRY.

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

          LOOP AT lt_sheet_data INTO DATA(ls_sheet_data) WHERE companycode IS NOT INITIAL.

            ls_fixed_Asset_excel-companycode = ls_sheet_data-companycode.
            ls_fixed_Asset_excel-masterfixedasset = |{ ls_sheet_data-masterfixedasset ALPHA = IN }|.
            ls_fixed_Asset_excel-fixedasset = |{ ls_sheet_data-fixedasset ALPHA = IN }|.
            ls_fixed_Asset_excel-ledger = ls_sheet_data-ledger.
            ls_fixed_Asset_excel-assetrealdepreciationarea = |{ ls_sheet_data-assetrealdepreciationarea ALPHA = IN }|.
            ls_fixed_Asset_excel-fixedassetdescription = ls_sheet_data-fixedassetdescription.
            ls_fixed_Asset_excel-depreciationkey = ls_sheet_data-depreciationkey.
            IF ls_fixed_Asset_excel-depreciationkey = '0'.
              ls_fixed_Asset_excel-depreciationkey = '0000'.
            ENDIF.

            APPEND ls_fixed_Asset_excel TO lt_fixed_asset_excel.

            MOVE-CORRESPONDING ls_fixed_Asset_excel TO ls_fixed_Asset_col.
            COLLECT ls_fixed_Asset_col INTO lt_fixed_Asset_col.

          ENDLOOP..


          request-fixed_asset_change_bulk_reques-message_header-creation_date_time = lv_timestamp.
          request-fixed_asset_change_bulk_reques-message_header-id-scheme_id = cl_system_uuid=>create_uuid_c32_static( ).
          request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id = cl_system_uuid=>create_uuid_c36_static( ).
          request-fixed_asset_change_bulk_reques-message_header-reference_uuid-scheme_id = request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id.

          LOOP AT lt_fixed_Asset_col INTO ls_fixed_Asset_col.

            CLEAR ls_fixed_asset_chn.
            ls_fixed_asset_chn-message_header-uuid-scheme_id = request-fixed_asset_change_bulk_reques-message_header-uuid-scheme_id.
            ls_fixed_asset_chn-message_header-creation_date_time = lv_timestamp.

            ls_fixed_asset_chn-fixed_asset-company_code =  ls_fixed_Asset_col-companycode.
            ls_fixed_asset_chn-fixed_asset-master_fixed_asset = ls_fixed_Asset_col-masterfixedasset.
            ls_fixed_asset_chn-fixed_asset-fixed_asset = ls_fixed_Asset_col-fixedasset.



            LOOP AT lt_fixed_asset_excel INTO ls_fixed_Asset_excel WHERE companycode = ls_fixed_Asset_col-companycode
                                                                     AND masterfixedasset = ls_fixed_Asset_col-masterfixedasset
                                                                     AND fixedasset = ls_fixed_Asset_col-fixedasset .

              ls_timevaluation-asset_depreciation_area = ls_fixed_Asset_excel-assetrealdepreciationarea.
              ls_timevaluation-depreciation_key = ls_fixed_Asset_excel-depreciationkey.
              ls_timevaluation-action_code = '02'.
              ls_timevaluation-validity_start_date = '19000101'.
              APPEND ls_timevaluation TO ls_fixed_asset_chn-fixed_asset-time_based_valuation.


              CLEAR ls_log.
              ls_log-assetrealdepreciationarea = ls_timevaluation-asset_depreciation_area.
              ls_log-companycode = ls_fixed_asset_chn-fixed_asset-company_code.
              ls_log-masterfixedasset = ls_fixed_asset_chn-fixed_asset-master_fixed_asset.
              ls_log-fixedasset = ls_fixed_asset_chn-fixed_asset-fixed_asset.
              ls_log-depreciationkey = ls_timevaluation-depreciation_key.
              ls_log-ledger = ls_fixed_Asset_excel-ledger.

              MODIFY zfi_fixed_asset FROM @ls_log.

            ENDLOOP.

            APPEND ls_fixed_asset_chn TO request-fixed_asset_change_bulk_reques-fixed_asset_change_request.

          ENDLOOP.

          proxy->fixed_asset_change_bulk_reques(
             EXPORTING
               input = request
           ).

        CATCH cx_ai_system_fault INTO DATA(lo_error).
          " handle error
        CATCH cx_root INTO DATA(lo_root).
      ENDTRY.

    ENDIF.


  ENDMETHOD.

ENDCLASS.
