CREATE OR REPLACE FUNCTION fnc_last_rate_usd(cur_id bigint) RETURNS SETOF currency AS
$$
SELECT *
FROM currency
WHERE id = cur_id
ORDER BY updated DESC
LIMIT 1;
$$ LANGUAGE SQL;

SELECT coalesce(u.name, 'not defined')             AS name,
       coalesce(u.lastname, 'not defined')         AS lastname,
       b.type                                      AS type,
       SUM(b.money)                                AS volume,
       coalesce(cur.name, 'not defined')           AS currency_name,
       coalesce(cur.rate_to_usd, 1)                AS last_rate_to_usd,
       SUM(b.money) * coalesce(cur.rate_to_usd, 1) AS total_volume_in_usd
FROM balance b
         LEFT JOIN public.user u ON b.user_id = u.id
         LEFT JOIN fnc_last_rate_usd(b.currency_id) AS cur ON cur.id = b.currency_id
GROUP BY u.name, u.lastname, b.type, cur.name,
         cur.rate_to_usd
ORDER BY name DESC, lastname ASC, type ASC;