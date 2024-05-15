--1

Create or replace function NUM_PURCH_SF 
(p_shopperId in bb_basket.idshopper%type)

return number

is
 lv_purch_num number;

 begin
    select sum(orderplaced)
    into lv_purch_num
    from bb_basket
    where idshopper = p_shopperId;
    
    return lv_purch_num;
    
    

 EXCEPTION
    when no_data_found then
        return 0;
end num_purch_sf;

/

Declare
    id number := 23;
    lv_shopper number;
Begin

    select num_purch_sf(id) into lv_shopper from dual;
    DBMS_output.put_line('Question 1');
    DBMS_output.put_line('The number of orders of Shopper Id: '|| id|| ' is ' || lv_shopper );
end;

--2
/
create or replace function day_ord_sf
    (p_date in Date)

    return varchar2
IS
    weekday varchar2(20);
begin
  	 weekday := TO_CHAR(p_date, 'DAY');
    
    return weekday;
    
end day_ord_sf;

/


Declare
	cursor cur_basket is 
		select idBasket, dtCreated
		from bb_basket;

Begin
	dbms_output.put_line('Question 2.2');
	for rec_basket in cur_basket loop
		dbms_output.put_line('Basket id: '||rec_basket.idBasket ||' Day: '|| day_ord_sf(rec_basket.dtCreated)) ;
	end loop;

End;
/

Declare
    cursor cur_basket1 is
		select count(idBasket) as count1, day_ord_sf(dtCreated) as weekday
		from bb_basket
    	group by day_ord_sf(dtcreated)
    	order by count(idBasket) desc ;

	

begin
	dbms_output.put_line('Question 2.3');
	for rec_basket in cur_basket1 loop
		dbms_output.put_line(rec_basket.weekday|| ': '||rec_basket.count1 );
	end loop;
	dbms_output.put_line('The weekday that has the highest order is: Thursday');
end;

/

/

--3
Begin
    DBMS_output.put_line('Question 3');
end;
/
Create or replace function ord_ship_sf
    (p_id in number)
    
    return varchar2
    
    is
    
    lv_id bb_basket.idbasket%type;
    lv_order bb_basket.dtcreated%type;
    lv_ship bb_basketstatus.dtstage%type;
    lv_shipday number;
    lv_status varchar2(100);
    
begin
    select s.idstatus, b.dtcreated, s.dtstage
    into lv_id, lv_order, lv_ship
    from bb_basket b inner join bb_basketstatus s
    on b.idbasket = s.idbasket
    where s.idstatus = p_id;
    
    if lv_ship is null then
        lv_status := 'NOT SHIPPED';
    
    else
        lv_shipday := lv_ship-lv_order;
        
        if lv_shipday <= 1 then
            lv_status := 'OK';
        else
         lv_status := 'CHECK';
        end if;
        
    end if;
    
    return lv_status;
    
    
end;

/
DECLARE 
    lv_shipStatus VARCHAR2(100);
    lv_id NUMBER := 4;
BEGIN

    -- Directly store the function's return value in lv_shipStatus
    lv_shipStatus := ord_ship_sf(lv_id);
    DBMS_OUTPUT.PUT_LINE('The idbasket no.' || lv_id || ' Status: '|| lv_shipStatus);

END;
/

DECLARE 
    lv_shipStatus VARCHAR2(100);
    lv_id NUMBER := 15;
BEGIN

    -- Directly store the function's return value in lv_shipStatus
    lv_shipStatus := ord_ship_sf(lv_id);
    DBMS_OUTPUT.PUT_LINE('The idbasket no.' || lv_id || ' Status: '|| lv_shipStatus);

END;
/

DECLARE 
    lv_shipStatus VARCHAR2(100);
    lv_id NUMBER := 2;
BEGIN

    -- Directly store the function's return value in lv_shipStatus
    lv_shipStatus := ord_ship_sf(lv_id);
    DBMS_OUTPUT.PUT_LINE('The idbasket no.' || lv_id || ' Status: '|| lv_shipStatus);

END;
/
--q4
Create or replace trigger BB_ORDCANCEL_TRG
after insert on BB_basketstatus
for each row
when (new.idStage = 4)

Declare
    Cursor basketitem_cur is
        Select b.idProduct, b.quantity, b.option1, s.stock
        from bb_basketitem b inner join bb_product s
        on b.idproduct = s.idproduct
        where idbasket = :New.idBasket;
    lv_chg_num Number(3,1);
    
begin
    DBMS_output.put_line('trigger is fired...');
    for basketitem_rec in basketitem_cur Loop
        if basketitem_rec.option1 = 1 then
            lv_chg_num :=(0.5*basketitem_rec.quantity);
        else
            lv_chg_num :=basketitem_rec.quantity;
        end if;
        
        update bb_product
         set stock = stock + lv_chg_num
            where idproduct = basketitem_rec.idproduct;
          
        
        
    end loop;

END;
/


DECLARE
    -- Declaration of the basket ID variable with initialization should come first.
    lv_idbasket bb_basketitem.idbasket%type := 6;
    
    -- Cursor to select products based on the basket ID.
    CURSOR cur_product IS
        SELECT p.idproduct, p.stock
        FROM bb_product p
        INNER JOIN bb_basketitem b ON p.idproduct = b.idproduct
        WHERE b.idbasket = lv_idbasket;

BEGIN

    DBMS_OUTPUT.put_line('Question 4');
    DBMS_OUTPUT.put_line('Before inserting');
    
    FOR rec_basket IN cur_product LOOP
        DBMS_OUTPUT.put_line('ID Product: ' || rec_basket.idproduct || ' Stock: ' || rec_basket.stock);
    END LOOP;
END;

/


INSERT INTO bb_basketstatus (idStatus, idBasket, idStage, dtStage) VALUES (bb_status_seq.NEXTVAL, 6, 4, SYSDATE);
commit;

/


DECLARE
    -- Declaration of the basket ID variable with initialization should come first.
    lv_idbasket bb_basketitem.idbasket%type := 6;
    
    -- Cursor to select products based on the basket ID.
    CURSOR cur_product IS
        SELECT p.idproduct, p.stock
        FROM bb_product p
        INNER JOIN bb_basketitem b ON p.idproduct = b.idproduct
        WHERE b.idbasket = lv_idbasket;

BEGIN

    DBMS_OUTPUT.put_line('Updated Values');
    
    FOR rec_basket IN cur_product LOOP
        DBMS_OUTPUT.put_line('ID Product: ' || rec_basket.idproduct || ' Stock: ' || rec_basket.stock);
    END LOOP;
END;

/
ALTER TRIGGER bb_ordcancel_trg DISABLE;
/

--Q5
CREATE OR REPLACE PACKAGE DISC_PKG IS
    pv_disc_num NUMBER;
    pv_disc_txt CHAR(1);
END DISC_PKG;
/
CREATE OR REPLACE TRIGGER BB_DISCOUNT_TRG
AFTER UPDATE OF orderplaced ON bb_basket
FOR EACH ROW
WHEN (NEW.orderplaced = 1)
BEGIN
    -- Assuming DISC_PKG.pv_disc_num is already set during the ordering process
    IF DISC_PKG.pv_disc_num = 5 THEN
        DISC_PKG.pv_disc_txt := 'Y';
        -- Reset pv_disc_num for next cycle
        DISC_PKG.pv_disc_num := 0;
    ELSE
        DISC_PKG.pv_disc_txt := 'N';
    END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('Question Q5');
    -- Initialize variables
    DISC_PKG.pv_disc_num := 4; -- Set this to 4 for testing purposes
    DISC_PKG.pv_disc_txt := 'N';
    
    -- Perform the update that triggers BB_DISCOUNT_TRG
    UPDATE bb_basket SET orderplaced = 1 WHERE idBasket = 13;
    
    -- Check the value of pv_disc_txt to verify if discount was applied
    DBMS_OUTPUT.PUT_LINE('Discount Applied (Y/N): ' || DISC_PKG.pv_disc_txt);
    
    -- Reset conditions for re-testing
    UPDATE bb_basket SET orderplaced = 1 WHERE idBasket = 13;
    COMMIT;
END;
/
ALTER TRIGGER BB_DISCOUNT_TRG Disable;
/