class ZCO_FIXED_ASSET_CHANGE_BULK_RE definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods FIXED_ASSET_CHANGE_BULK_REQUES
    importing
      !INPUT type ZFIXED_ASSET_CHANGE_BULK_REQU1
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZCO_FIXED_ASSET_CHANGE_BULK_RE IMPLEMENTATION.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZCO_FIXED_ASSET_CHANGE_BULK_RE'
    logical_port_name   = logical_port_name
    destination         = destination
  ).

  endmethod.


  method FIXED_ASSET_CHANGE_BULK_REQUES.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'FIXED_ASSET_CHANGE_BULK_REQUES'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
