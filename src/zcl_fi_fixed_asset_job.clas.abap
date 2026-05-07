CLASS zcl_fi_fixed_asset_job DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
   INTERFACES if_apj_rt_run.
   DATA: mv_fixed_Asset TYPE char40.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_FI_FIXED_ASSET_JOB IMPLEMENTATION.


 METHOD if_apj_rt_run~execute.

        data ls_log type zfi_fix_asset_lg.
        ls_log-fixed_asset = mv_fixed_Asset.
        ls_log-datum = sy-datum.
        ls_log-uzeit = sy-uzeit.

        insert zfi_fix_asset_lg from @ls_log.



        commit WORK.


 ENDMETHOD.
ENDCLASS.
