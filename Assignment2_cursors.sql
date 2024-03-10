--4.9
DECLARE 
    CURSOR cur_pledge IS
        SELECT dp.iddonor, dp.IDpledge, dp.paymonths, dp.pledgeamt, dpm.paydate, dpm.payamt
            FROM dd_pledge dp INNER JOIN dd_payment dpm 
                ON dp.idpledge = dpm.idpledge
        WHERE dp.iddonor = 309
        ORDER BY dp.idpledge, dpm.paydate;

    prev_idpledge dd_pledge.idpledge%TYPE := Null; 
    first_payment BOOLEAN := TRUE; 

BEGIN
    FOR rec_pledge IN cur_pledge LOOP
        
        IF prev_idpledge IS NULL OR rec_pledge.idpledge != prev_idpledge THEN
            first_payment := TRUE;
        END IF;
        
        
        IF first_payment THEN
            DBMS_OUTPUT.put_line('First Payment: ' );
            DBMS_OUTPUT.PUT_LINE('ID: '|| rec_pledge.idpledge  );
            DBMS_OUTPUT.PUT_LINE('Pledge Amount: '|| rec_pledge.pledgeamt);
            DBMS_OUTPUT.PUT_LINE('Pay Month: '|| rec_pledge.paymonths );
            DBMS_OUTPUT.PUT_LINE('Pay Date: '|| rec_pledge.paydate );
            DBMS_OUTPUT.PUT_LINE('Pay Amount: '|| rec_pledge.payamt || chr(10));
            
            first_payment := FALSE; 
        ELSE
            
            DBMS_OUTPUT.PUT_LINE('ID: '|| rec_pledge.idpledge  );
            DBMS_OUTPUT.PUT_LINE('Pledge Amount: '|| rec_pledge.pledgeamt);
            DBMS_OUTPUT.PUT_LINE('Pay Month: '|| rec_pledge.paymonths );
            DBMS_OUTPUT.PUT_LINE('Pay Date: '|| rec_pledge.paydate );
            DBMS_OUTPUT.PUT_LINE('Pay Amount: '|| rec_pledge.payamt || chr(10));
        END IF;

        prev_idpledge := rec_pledge.idpledge;
    END LOOP;
END;
/

--4.11
DECLARE 
    CURSOR cur_donor(p_type CHAR, p_amt NUMBER) IS
        SELECT d.firstname, d.lastname, p.pledgeamt
        FROM dd_donor d
        INNER JOIN dd_pledge p ON d.iddonor = p.iddonor
        WHERE d.typecode = p_type AND p.pledgeamt >= p_amt;
        
    lv_type1_char dd_donor.typecode%TYPE := 'I';
    lv_type2_char dd_donor.typecode%TYPE := 'B';

    lv_amt1_num dd_pledge.pledgeamt%TYPE := 250;
    lv_amt2_num dd_pledge.pledgeamt%TYPE := 200;
    
    lv_type CHAR;
    lv_amt NUMBER;
BEGIN
    FOR rec_donor IN cur_donor(lv_type1_char, lv_amt1_num) LOOP
        lv_type := lv_type1_char;
        lv_amt := lv_amt1_num;
        
        DBMS_OUTPUT.put_line('Name: ' || rec_donor.firstname || ' ' || rec_donor.lastname);
        DBMS_OUTPUT.put_line('Pledge Amount: ' || rec_donor.pledgeamt || CHR(10));
    END LOOP;
    
    FOR rec_donor IN cur_donor(lv_type2_char, lv_amt2_num) LOOP
        lv_type := lv_type2_char;
        lv_amt := lv_amt2_num;
        
        DBMS_OUTPUT.put_line('Name: ' || rec_donor.firstname || ' ' || rec_donor.lastname);
        DBMS_OUTPUT.put_line('Pledge Amount: ' || rec_donor.pledgeamt || CHR(10));
    END LOOP;
    
   
END;

/


--4.12

Declare
	cv_donor Sys_refcursor;

	type recDetail is record(
        payamt dd_payment.payamt%type,
        idpledge dd_payment.idpledge%type,
        iddonor dd_pledge.iddonor%type
    );


	rec_detail	recDetail;

	type recSum is record(
        total number,
        iddonor dd_pledge.iddonor%type,
        idpledge dd_pledge.idpledge%type
        
    );

	rec_summary recsum;


	lv_input_donorid number := 301;
	lv_input_indicator char := 'S';

begin
	if lv_input_indicator = 'D' then
        DBMS_output.put_line('Detailed Report');
		open cv_donor for 
    		select py.payamt, py.idpledge, pl.iddonor from dd_payment py
				inner join dd_pledge pl on py.idpledge = pl.idpledge
				where pl.iddonor = lv_input_donorid
                order by pl.iddonor, py.idpledge;
				
		loop 
        
            
			fetch cv_donor into rec_detail;
			exit when cv_donor%notfound;
			
            DBMS_output.put_line('id donor :' || rec_detail.iddonor);
			DBMS_output.put_line('id pledge :' || rec_detail.idpledge);
			DBMS_output.put_line('pay amount :' || rec_detail.payamt || chr(10));
        
		end loop;

	elsif lv_input_indicator = 'S' then
        DBMS_output.put_line('Summary Report');
		open cv_donor for
			select sum(py.payamt) as total, pl.iddonor, py.idpledge from dd_payment py
            inner join dd_pledge pl on py.idpledge = pl.idpledge
			where pl. iddonor = lv_input_donorid
        	group by pl.iddonor, py.idpledge;
		loop 
			fetch cv_donor into rec_summary;
			exit when cv_donor%notfound;
			DBMS_output.put_line('Donor id :' || rec_summary.iddonor );
            DBMS_output.put_line('Id pledge :' ||  rec_summary.idpledge);
            DBMS_output.put_line('Total :'|| rec_summary.total || CHR(10));
		end loop;
	end if;
end;

/


--4.13
Declare
    ex_dup_id exception;
    pragma exception_init(ex_dup_id,-00001);
BEGIN
    update dd_donor
        set iddonor = 306
        where iddonor = 305;
Exception
    when ex_dup_id then
        DBMS_output.put_line('This ID is already assigned');
end;
