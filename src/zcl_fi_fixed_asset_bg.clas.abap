CLASS zcl_fi_fixed_asset_bg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA: mv_file_content TYPE xstring.
    INTERFACES if_bgmc_op_single_tx_uncontr .
    METHODS constructor IMPORTING iv_content TYPE xstring.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_FIXED_ASSET_BG IMPLEMENTATION.


METHOD constructor.
    me->mv_file_content = iv_content.
  ENDMETHOD.


  METHOD if_bgmc_op_single_tx_uncontr~execute.
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

   " Error handling in case file content is initial

    DATA(lo_document) = xco_cp_xlsx=>document->for_file_content( me->mv_file_content )->read_access( ).

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

          ls_fixed_asset_chn-fixed_asset-company_code =  ls_sheet_data-companycode.
          ls_fixed_asset_chn-fixed_asset-master_fixed_asset = ls_sheet_data-masterfixedasset.
          ls_fixed_asset_chn-fixed_asset-fixed_asset = ls_sheet_data-fixedasset.

          LOOP AT lt_fixed_asset_excel INTO ls_fixed_Asset_excel WHERE companycode = ls_fixed_Asset_col-companycode
                                                                   AND masterfixedasset = ls_fixed_Asset_col-masterfixedasset
                                                                   AND fixedasset = ls_fixed_Asset_col-fixedasset .

            ls_timevaluation-asset_depreciation_area = ls_fixed_Asset_excel-assetrealdepreciationarea.
            ls_timevaluation-depreciation_key = ls_fixed_Asset_excel-depreciationkey.
            ls_timevaluation-action_code = '02'.
            ls_timevaluation-validity_start_date = '19000101'.
            APPEND ls_timevaluation TO ls_fixed_asset_chn-fixed_asset-time_based_valuation.

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


  ENDMETHOD.
ENDCLASS.
