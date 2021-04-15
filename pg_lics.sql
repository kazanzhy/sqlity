/* 
 * Checks if INT in Longest Increasinc Consequent Sequence from 1 by 1
 * Run in ordered window on integer column. 
 */
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TYPE IF EXISTS corr_seq_state CASCADE;
CREATE TYPE corr_seq_state AS (max_given INTEGER, correct_sequence bool);
---------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS corr_seq_row CASCADE;
CREATE FUNCTION corr_seq_row (prev corr_seq_state, dose INTEGER) RETURNS corr_seq_state AS $$
	BEGIN
		IF dose = (prev.max_given + 1) THEN RETURN (dose, TRUE);
		ELSEIF dose <= prev.max_given THEN RETURN (prev.max_given, TRUE);		
		ELSE RETURN (prev.max_given, FALSE);
		END IF;
    END;
$$ LANGUAGE plpgsql; 
---------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS corr_seq_final CASCADE;
CREATE FUNCTION corr_seq_final (curr amon.corr_seq_state) RETURNS BOOL AS $$
    BEGIN
		RETURN curr.correct_sequence;		
    END;
$$ LANGUAGE plpgsql; 
---------------------------------------------------------------------------------------------------
DROP AGGREGATE IF EXISTS corr_seq (INTEGER) CASCADE;
CREATE AGGREGATE corr_seq (INTEGER) (
	-- Run in EXPANDING window on integer column. Returns TRUE current int is in Increasing Subsequence from 1 by 1. 
    SFUNC = corr_seq_row, 
    STYPE = corr_seq_state, 
    FINALFUNC = corr_seq_final,
    INITCOND = '(0, FALSE)'
);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Test 1
with temp_table_1 as (select unnest('{2,1,1,2,1,3,6,4}'::int[]) as seq
	)
SELECT *, corr_seq(seq) over (order by seq)
from temp_table_1;
---------------------------------------------------------------------------------------
-- Test 2
with temp_table_2 as (
	select 'Sars-Cov-2' as vaccine_disease,
		unnest('{2,1,1,2,1,3,6,4}'::int[]) as vaccine_dose,
		generate_series('2021-01-21', '2021-04-22', interval '13 days') as vaccine_date
	)
SELECT *, corr_seq(vaccine_dose) over byVac as is_correct_sequence
from temp_table_2
window byVac as (partition by vaccine_disease order by vaccine_date);
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
