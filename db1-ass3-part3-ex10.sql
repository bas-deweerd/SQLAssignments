-- 1. Write a procedure which displays the names of those vice-presidents who also became president, and
-- stores these in a new temporary table.
DROP FUNCTION bothPresAndVicePres();

CREATE OR REPLACE FUNCTION bothPresAndVicePres()
RETURNS TABLE(namesOfPresidents varChar) AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR 
	SELECT name FROM president WHERE name IN (SELECT vice_pres_name FROM admin_vpres);
BEGIN
	FOR record_variable IN cursor1 LOOP
		SELECT record_variable.name INTO namesOfPresidents;
		RETURN NEXT;
	END LOOP;
END;
$$ LANGUAGE plpgsql;
	
SELECT bothPresAndVicePres();

-- 2. Write a procedure which displays the names and birth years of all presidents who are not married
-- yet, and stores the result in a new temporary table.
DROP FUNCTION allPresidentsWhoAreNotMarriedYet();

CREATE OR REPLACE FUNCTION allPresidentsWhoAreNotMarriedYet()
RETURNS TABLE(nameOfPresident varChar, birthYear int) AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR
	SELECT name, birth_year FROM president WHERE id NOT IN(SELECT pres_id FROM pres_marriage);
BEGIN
	FOR record_variable IN cursor1 LOOP
		SELECT record_variable.name INTO nameOfPresident;
		SELECT record_variable.birth_year INTO birthYear;
		RETURN NEXT;
	END LOOP;
END;
$$ LANGUAGE plpgsql;
	
SELECT * FROM allPresidentsWhoAreNotMarriedYet();

-- 3. Write a procedure which displays the name of a given president’s spouse(s), and stores these in a
-- new temporary table.
DROP FUNCTION getSpouseName(presidentName varChar)

CREATE OR REPLACE FUNCTION getSpouseName(presidentName varChar)
RETURNS void AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR
	SELECT spouse_name FROM pres_marriage WHERE pres_id IN (SELECT id from PRESIDENT WHERE name = presidentName);
BEGIN
	CREATE LOCAL TEMPORARY TABLE temp_presi(pres_name varchar(20));

	FOR record_variable IN cursor1 LOOP
		INSERT INTO temp_presi VALUES (record_variable.spouse_name);
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT getSpouseName('TYLER J');

SELECT * FROM temp_presi;

-- 4. Write a procedure which displays a given president’s hobbies, and stores these in a new temporary
-- table.
DROP FUNCTION getPresidentHobbies(presidentName varChar)

CREATE OR REPLACE FUNCTION getPresidentHobbies(presidentName varChar)
RETURNS void AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR
	SELECT hobby FROM pres_hobby WHERE pres_id IN (SELECT id FROM president WHERE name = presidentName);
BEGIN
	CREATE LOCAL TEMPORARY TABLE temp_hobbies(hobby varChar);
	FOR record_variable IN cursor1 LOOP
		INSERT INTO temp_hobbies VALUES (record_variable.hobby);
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT getPresidentHobbies('WASHINGTON G');

SELECT * FROM temp_hobbies;

DROP TABLE temp_hobbies;

-- 5. Write a procedure which displays all vice-presidents who served with a given president, and stores
-- them in a new temporary table.
DROP FUNCTION getVicePresidentsUnderPresident(presidentName varChar);

CREATE OR REPLACE FUNCTION getVicePresidentsUnderPresident(presidentName varChar)
RETURNS void AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR
	SELECT DISTINCT vice_pres_name FROM admin_vpres WHERE admin_id IN (SELECT admin_nr FROM administration WHERE pres_id IN (SELECT id FROM president WHERE name = presidentName));
BEGIN
	CREATE LOCAL TEMPORARY TABLE temp_vice_pres(vicePresName varChar);
	FOR record_variable IN cursor1 LOOP
		INSERT INTO temp_vice_pres VALUES (record_variable.vice_pres_name);
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT getVicePresidentsUnderPresident('WASHINGTON G');

SELECT * FROM temp_vice_pres

DROP TABLE temp_vice_pres

-- 6. Write a procedure which displays the names of all presidents of a given party, and stores these in a
-- new temporary table.

DROP FUNCTION getPresidentsByParty(partyName varChar);

CREATE OR REPLACE FUNCTION getPresidentsByParty(PartyName varChar)
RETURNS void AS $$
DECLARE
	record_variable record;
	cursor1 CURSOR FOR
	SELECT DISTINCT name FROM president WHERE party = partyName;
BEGIN
	CREATE LOCAL TEMPORARY TABLE temp_presidents(presidentName varChar);
	FOR record_variable IN cursor1 LOOP
		INSERT INTO temp_presidents VALUES (record_variable.name);
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT getPresidentsByParty('DEMO-REP');

SELECT * FROM temp_presidents