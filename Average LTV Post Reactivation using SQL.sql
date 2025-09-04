   USE zebedee;
   #TABLE NAME: tbl_media_chnl_post_ltv

SELECT 
    ru.media_channel,
    COUNT(DISTINCT ru.visitor_id) AS reactivated_users,
    CAST(AVG(post_ltv.post_reactivation_ltv) AS DECIMAL(12,2)) AS avg_post_ltv 
    FROM ( 
##Inner Joining the revenue table with mapping table by UserID and then we also inner-joined with the reactivation user table (which was achieved in last query) with visitor id, to find the total post reactivation revenue
 SELECT
        m.vst_id as visitor_id,
        ####SUM(r.revenue) AS post_reactivation_ltv
        ####Since we have comma in revenue field, we faced the calculation issue. Therefore, we are using replace function then applied decimal to get correct value of revenue. 
        SUM(CAST(REPLACE(r.revenue, ',', '') AS DECIMAL(12,2))) AS post_reactivation_ltv
    FROM revenues r
    INNER JOIN mapping m ON r.user_id = m.id
    INNER JOIN tbl_dormant_usr_re_activation ru ON m.vst_id = ru.visitor_id
    WHERE r.period >= ru.reactivation_date  -- revenue only after reactivation
    GROUP BY m.vst_id
)post_ltv
#Again we Inner joined with the reactivation user table to get the average post LTV and count of reactivation users with media channel.
INNER JOIN tbl_dormant_usr_re_activation ru
 ON ru.visitor_id = post_ltv.visitor_id
GROUP BY ru.media_channel
ORDER BY avg_post_ltv DESC;

