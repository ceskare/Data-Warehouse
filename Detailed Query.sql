INSERT INTO currency
VALUES (100, 'EUR', 0.85, '2022-01-01 13:29');
INSERT INTO currency
VALUES (100, 'EUR', 0.79, '2022-01-08 13:29');

DROP FUNCTION IF EXISTS fnc_cur_rate;

CREATE OR REPLACE FUNCTION fnc_cur_rate(cur_id BIGINT, updat TIMESTAMP)
    RETURNS TABLE
            (
                name        VARCHAR,
                id          BIGINT,
                rate_to_usd NUMERIC
            )
AS
$$
SELECT name,
       id,
       COALESCE(
               (SELECT rate_to_usd
                FROM currency
                WHERE id = cur_id
                  AND updated < updat
                ORDER BY updated DESC
                LIMIT 1),
               (SELECT rate_to_usd
                FROM currency
                WHERE id = cur_id
                  AND updated > updat
                ORDER BY updated ASC
                LIMIT 1)
           ) AS rate_to_usd
FROM currency
WHERE id = cur_id;
$$ LANGUAGE SQL;

SELECT DISTINCT coalesce(u.name, 'not defined')     AS name,
                coalesce(u.lastname, 'not defined') AS lastname,
                cur.name                            AS currency_name,
                cur.rate_to_usd * b.money           AS currency_in_usd
FROM balance b
         LEFT JOIN public.user u ON b.user_id = u.id
         JOIN fnc_cur_rate(b.currency_id, b.updated) AS cur ON cur.id = b.currency_id
ORDER BY name DESC, lastname ASC, currency_name ASC;