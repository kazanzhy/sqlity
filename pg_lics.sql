/*
 * Longest increasinc consequent sequence
 * 
 * Run in ordered window on integer column
 * Returns last value of longest subsequence from 1 and increasing by 1.
 */

--------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS lics_row CASCADE;
CREATE FUNCTION lics_row (prev_max INTEGER, curr INTEGER) RETURNS INTEGER AS $$
    BEGIN
        IF curr = (prev_max + 1) THEN RETURN curr;
		ELSE RETURN prev_max;		
        END IF;
    END;
$$ LANGUAGE plpgsql; 
--------------------------------------------------------------------------------------------------------------------------------
DROP AGGREGATE IF EXISTS lics (INTEGER) CASCADE;
CREATE AGGREGATE lics (INTEGER) (
    SFUNC = lics_row, 
    STYPE = INTEGER, 
    INITCOND = '0'
);
--------------------------------------------------------------------------------------------------------------------------------
-- Test 1
with temp_table_1 as (select unnest('{2,1,1,2,1,3,6,4}'::int[]) as seq
	)
SELECT *, lics(seq) over (order by seq)
from temp_table_2

---------------------------------------------------------------------------------------
-- Test 2
with temp_table_2 as (
	select 'Sars-Cov-2' as vaccine_disease,
		unnest('{2,1,1,2,1,3,6,4}'::int[]) as vaccine_dose,
		generate_series('2021-01-21', '2021-04-22', interval '13 days') as vaccine_date
	)
SELECT *, 
	lics(vaccine_dose) over byVac as max_longest_seq,
	vaccine_dose <= lics(vaccine_dose) over byVac as is_correct_sequence
from temp_table_2
window byVac as (partition by vaccine_disease order by vaccine_date)


