create or replace package pkg_372_group_project 
as
    procedure topincountry
        (p_country varchar2);
    
    procedure monthly_earnings;
    
    procedure creatorinfo
        (p_creator varchar2);
    
    procedure video_views
        (p_year in number);
    
    procedure highestPops;
    
    procedure uploads_rank;
    
    procedure upload_subs_ratio
        (p_youtuber in varchar2);
    
    procedure lowestteredu;
    
    procedure popcat;
    
    procedure highestunemployed;
    
end pkg_372_group_project;

create or replace package body pkg_372_group_project
as
    
    procedure topincountry(p_country varchar2) as
        v_topyoutuber varchar2(50);
    begin
        select c.youtuber into v_topyoutuber 
        from creator c inner join subscribers s on c.youtuber = s.youtuber
        where country = p_country
        order by subscriberamount desc fetch first 1 rows only;
        dbms_output.put_line('The youtuber with the most subscribers in ' || p_country || ' is ' || v_topyoutuber);
    end topincountry;

-- Question 2
    procedure monthly_earnings
    as

        v_max_monthly_earnings creator.highest_monthly_earnings%type;
        v_youtuber creator.youtuber%type;
    
    begin
    
        select youtuber, max(highest_monthly_earnings) 
            into v_youtuber, v_max_monthly_earnings
        from creator
        group by youtuber
        order by max(highest_monthly_earnings) desc
        fetch first 1 rows only;
    
        dbms_output.put_line('The Youtuber with the Highest Monthly Earnings is ' || v_youtuber || ' with the monthly earnings of ' || v_max_monthly_earnings);
    end monthly_earnings;

-- Question 3

    procedure creatorinfo(p_creator varchar2) as
        v_rank number;
        v_cat varchar2(50);
        v_country varchar2(50);
        v_countryrank number;
        v_highestmonthlyearnings number(10,2);
    begin
        select rank, category, country, country_rank, highest_monthly_earnings 
            into v_rank, v_cat, v_country, v_countryrank, v_highestmonthlyearnings
        from creator where youtuber = p_creator;
        dbms_output.put_line('Youtuber: ' || p_creator || ' rank: ' 
        || v_rank || ' category: ' || v_cat || ' country: ' || v_country || ' country rank: ' 
        || v_countryrank || ' top monthly earnings ' || v_highestmonthlyearnings);
    end creatorinfo;

-- Question 4

    procedure video_views
        (p_year in number)
    as

        v_video_views_rank content.video_views_rank%type;
        v_youtuber content.youtuber%type;
    
    begin

        select youtuber, max(video_views_rank)
            into v_youtuber, v_video_views_rank
        from content
        where created_year = p_year
        group by youtuber
        order by max(video_views_rank)
        fetch first 1 rows only;
    
        dbms_output.put_line(v_youtuber || ' is ranked at ' || v_video_views_rank || ' and has the created year of ' || p_year);
     
    end video_views;

-- Question 5
    procedure highestPops as

        cursor countries is select * from country order by population desc;
        cur_country country%rowtype;
        v_countryname varchar2(30);
        v_population number;
        v_urban_pop number;

    begin
        open countries;
        for i in 1 .. 10 loop
            fetch countries into cur_country;
            v_population := cur_country.population;
            v_urban_pop := cur_country.urban_population;
            v_countryname := cur_country.country;
            dbms_output.put_line(v_countryname || ' has a population of: ' || v_population || ' and an urban population of ' || v_urban_pop);
        end loop;
        close countries;
    end;

-- Question 6

    procedure uploads_rank as
    
        cursor upload_rank is
            select * from content
            order by uploads desc;
    
        cur_rank content%rowtype;
        v_youtuber varchar2(30);
        v_uploads number;
        v_rank number;
        
    begin
        
        open upload_rank;
        for i in 1 .. 10 loop
            fetch upload_rank into cur_rank;
            v_youtuber := cur_rank.youtuber;
            v_uploads := cur_rank.uploads;
            v_rank := cur_rank.video_views_rank;
            dbms_output.put_line(v_youtuber || ' has ' || v_uploads || ' uploads and is ranked number ' || v_rank);
        end loop;
        close upload_rank;
    end uploads_rank;

-- Question 7

    procedure upload_subs_ratio
        (p_youtuber in varchar2)
    as
        cursor uploads_subs is
            select c.uploads, s.subscriberamount
            from content c inner join subscribers s
            on c.youtuber = s.youtuber
            where c.youtuber = p_youtuber;
        
        v_uploads number;
        v_subs number;
    begin
        open uploads_subs;
        
        fetch uploads_subs into v_uploads, v_subs;
        
        dbms_output.put_line(p_youtuber || ' has a Subscriber:Uploads Ratio of ' || v_subs / v_uploads);
        
        close uploads_subs;
    end upload_subs_ratio;

-- Question 8
    procedure lowestteredu as

        cursor all_countries is 
            select country, population * gross_tertiary_education_enrollment as num_tertiary 
            from country
            where population != 0 OR gross_tertiary_education_enrollment != 0
            order by population * gross_tertiary_education_enrollment asc;
        
        cur_country all_countries%rowtype;
        v_cur_num_tertiary number;
        v_cur_countryname varchar2(20);
    
    begin
        open all_countries;
        
        for i in 1 .. 10 loop
            fetch all_countries into cur_country;
            v_cur_countryname := cur_country.country;
            v_cur_num_tertiary := cur_country.num_tertiary;
            dbms_output.put_line(v_cur_countryname || ' has a population who have a tertiary education of ' || v_cur_num_tertiary);
        end loop;
        close all_countries;
    end lowestteredu;

--9
    procedure popcat as 

        cursor all_cats is 
            select c.category, sum(s.subscriberamount) as subamount 
            from creator c inner join subscribers s 
            on c.youtuber = s.youtuber
            where c.category is not null
            group by category
            order by sum(s.subscriberamount) desc;
        
        cur_cat all_cats%rowtype;
        v_catname varchar2(40);
        v_catsubcount number;
    
    begin
        open all_cats;
        for i in 1 .. 10 loop
            fetch all_cats into cur_cat;
            v_catname := cur_cat.category;
            v_catsubcount := cur_cat.subamount;
            dbms_output.put_line(v_catname || ': has ' || v_catsubcount || ' total subscribers');
        end loop;
        close all_cats;
    end;

--10
    procedure highestunemployed as

        cursor all_countries is 
            select country, population * unemployment_rate as num_unem
            from country
            order by population * unemployment_rate desc;
            
        cur_country all_countries%rowtype;
        v_cur_num_unem number;
        v_cur_countryname varchar2(20);
    
    begin
        open all_countries;
        
        for i in 1 .. 10 loop
            fetch all_countries into cur_country;
            v_cur_countryname := cur_country.country;
            v_cur_num_unem := cur_country.num_unem;
            dbms_output.put_line(v_cur_countryname || ' has an unemployed population of ' || v_cur_num_unem);
        end loop;
        close all_countries;
    end highestunemployed;
end pkg_372_group_project;
    