
/*
 * Calculates the Levenshtein or Damerau-Levenshtein editing distance
 * if third parameter TRUE then works Damerau-Levenshtein
 */

--------------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS levenshtein CASCADE;
CREATE FUNCTION levenshtein (TEXT, TEXT, damerau BOOL default FALSE) RETURNS INT STRICT AS $$
	DECLARE 
		fst TEXT := lower($1);
		snd TEXT := lower($2);
		flen INT := length(fst) + 1;
		slen INT := length(snd) + 1;
		D INT[][] := array_fill(0, array[flen, slen]);
		cst INT; del INT; ins INT; sub INT;
	BEGIN
		FOR i IN 1 .. flen LOOP 
			D[i][1] := i-1;
		END LOOP;
		FOR j IN 1 .. slen LOOP
			D[1][j] := j-1;
		END LOOP;
	    ---
		FOR i IN 2 .. flen LOOP 
			FOR j IN 2 .. slen LOOP
				cst = (substring(fst,i-1,1) <> substring(snd,j-1,1))::int;
				del := D[i-1][j] + 1; -- deletion
				ins := D[i][j-1] + 1; -- insertion
				sub := D[i-1][j-1] + cst; -- substitution
				D[i][j] := least(del, ins, sub);
				IF damerau and i > 3 and j > 3 and substring(fst,i-1,1) = substring(snd,j-2,1) and substring(fst,i-2,1) = substring(snd,j-1,1) THEN
					D[i][j] := least(D[i][j], D[i-2][j-2] + 1);  -- transposition
				END IF;
			END LOOP;
		END LOOP;
		RETURN D[flen][slen];		
	END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------------------------------------------------------------------
                
-- Test
with
tmp as (select 'EDITING' as fst, 'DISTANCE' as snd
		union select 'Строка', 'собака'
		union select 'НСЗУ', 'НЗСУ'
		union select 'book', 'back'
	)
select fst, snd, levenshtein(fst, snd), levenshtein(fst, snd, true) as levenshtein_damerau
from tmp
