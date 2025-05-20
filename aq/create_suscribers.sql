BEGIN
  DBMS_AQADM.ADD_SUBSCRIBER(
    Queue_name => 'orders_msg_queue',
    Subscriber => sys.aq$_agent('US_ORDERS', null, null),
    Rule       => 'tab.user_data.region_code = ''USA''');
END;
/

CREATE OR REPLACE FUNCTION fn_Dollars_to_Euro(src IN orders_message_type)
RETURN orders_message_type
AS
  Target orders_message_type;
  europe_region CONSTANT VARCHAR2(10) := 'EUROPE';
  ratio CONSTANT NUMBER := 0.9;
BEGIN
  Target :=
    aq_admin.orders_message_type(
      src.order_id,
      src.product_code, src.customer_id,
      src.order_details, src.price * ratio,
      europe_region);
  RETURN Target;
END fn_Dollars_to_Euro;
/

CREATE OR REPLACE FUNCTION fn_Dollars_to_Pesos(src IN orders_message_type)
RETURN orders_message_type
AS
  Target orders_message_type;
  mexico_region CONSTANT VARCHAR2(10) := 'MEXICO';
  ratio CONSTANT NUMBER := 0.5; 
BEGIN
  Target :=
    aq_admin.orders_message_type(
      src.order_id,
      src.product_code, src.customer_id,
      src.order_details, src.price * ratio,
      mexico_region);
  RETURN Target;
END fn_Dollars_to_Pesos;
/

BEGIN
  DBMS_TRANSFORM.CREATE_TRANSFORMATION(
    schema =>      'AQ_ADMIN',
    name =>        'DOLLAR_TO_PESOS',
    from_schema => 'AQ_ADMIN',
    from_type =>   'ORDERS_MESSAGE_TYPE',
    to_schema =>   'AQ_ADMIN',
    to_type =>     'ORDERS_MESSAGE_TYPE',
    transformation => 'AQ_ADMIN.FN_DOLLARS_TO_PESOS(SOURCE.USER_DATA)');
END;
/

BEGIN
  DBMS_TRANSFORM.CREATE_TRANSFORMATION(
    schema =>      'AQ_ADMIN',
    name =>        'DOLLAR_TO_EURO',
    from_schema => 'AQ_ADMIN',
    from_type =>   'ORDERS_MESSAGE_TYPE',
    to_schema =>   'AQ_ADMIN',
    to_type =>     'ORDERS_MESSAGE_TYPE',
    transformation => 'AQ_ADMIN.FN_DOLLARS_TO_EURO(SOURCE.USER_DATA)');
END;
/

BEGIN
  DBMS_AQADM.ADD_SUBSCRIBER(
    Queue_name => 'orders_msg_queue',
    Subscriber => sys.aq$_agent('PESOS_ORDERS', null, null),
    Rule       => 'tab.user_data.region_code = ''MEXICO''',
    Transformation =>  'DOLLAR_TO_PESOS');
END;
/

BEGIN
  DBMS_AQADM.ADD_SUBSCRIBER(
    Queue_name => 'orders_msg_queue',
    Subscriber => sys.aq$_agent('EUROPE_ORDERS', null, null),
    Rule       => 'tab.user_data.region_code = ''EUROPE''',
    Transformation =>  'DOLLAR_TO_EURO');
END;
/
