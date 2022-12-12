-- 1
-- Elabore um trigger que mantenha o preço total de uma encomenda atualizado.
-- Crie uma encomenda com 5 itens. Teste o trigger, após a inserção, atualização
-- das quantidades e eliminação. (Tabelas utilizadas lineitem e orders)

create or replace function trigger_ex1() 
returns trigger 
as $$
declare
	li_order record;
	li_r record;
begin
	-- apanha a order
	select * into li_order from orders where o_orderkey = NEW.l_orderkey;
	-- mete o total price a zero
	update orders set o_totalprice = 0 where o_orderkey = li_order.o_orderkey;
	
	-- por cada lineitem daquela order
	for li_r in select * from lineitem where l_orderkey = li_order.o_orderkey
    loop 
		-- somar ao totalprice do order
		li_order.o_totalprice = li_order.o_totalprice + li_r.l_extendedprice;
    end loop;
	
	raise notice 'Order %''s total price updated.', li_order.o_orderkey;
    return new;
end; $$ 
language plpgsql;

create or replace trigger update_orders
before insert or update or delete on lineitem
for each row execute function trigger_ex1();

-- 2
-- Faça um trigger que não permita que um cliente mude de nacionalidade

create or replace function trigger_ex2() 
returns trigger 
as $$
begin
	if old.c_nationkey != new.c_nationkey then
		raise exception 'You can''t update the nationality.';
        return old;
	end if;
    return new;
end; $$ 
language plpgsql;

create or replace trigger deny_change_nationality
before update on customer
for each row execute function trigger_ex2();

-- 3
-- Crie um trigger que seja chamado sempre que se tentar alterar a prioridade de uma 
-- encomenda para um valor inferior ao antigo.

create or replace function trigger_ex3() 
returns trigger 
as $$
begin
	if cast(substring(new.o_orderpriority, 0, 2) as integer) < cast(substring(old.o_orderpriority, 0, 2) as integer) then
		raise exception 'You can''t change the priority to a lower value';
		return old;
	end if;
	return new;
end; $$ 
language plpgsql;

create or replace trigger deny_lower_priority
before update on orders
for each row execute function trigger_ex3();

-- 4
-- Desenvolva um trigger que seja chamado sempre que um utilizador tentar realizar alguma 
-- operação sobre a tabela das encomendas fora do seu horário de trabalho.

create or replace function trigger_ex4() 
returns trigger 
as $$
declare 
	hour integer := extract(hour from now());
begin
	if hour < 9 and hour > 13 then
		raise exception 'You can''t change orders after hours';
		return old;
	end if;
	return new;
end; $$ 
language plpgsql;

create or replace trigger deny_after_hours
before insert or delete or update on orders
for each row execute function trigger_ex4();

-- 5
-- Implemente um trigger que aumente o preço dos itens (coluna ps_supplycost/tabela 
-- partssupp) em 10%, quando a quantidade em stock atingir o mínimo de 2 (ps_avaliqty)

create or replace function trigger_ex5() 
returns trigger 
as $$
begin
	if new.ps_availqty < 2 then
		new.ps_supplycost = new.ps_supplycost * 1.1;
		raise notice 'Supply cost raised 10%%';
	end if;
	return new;
end; $$ 
language plpgsql;

create or replace trigger raise_10_when_2
before update on partsupp
for each row execute function trigger_ex5();

-- 6
-- Elabore um trigger que guarde numa tabela auxiliar, o nome do utilizador que realiza 
-- qualquer tipo de operações na tabela “região”. Deve criar uma tabela auxiliar para esse 
-- efeito

create or replace function trigger_ex6() 
returns trigger 
as $$
begin
	create table if not exists aux_users(aux_id integer primary key, nome varchar(50), ts timestamp default now());
	insert into aux_users(aux_id, nome) values (
		(select coalesce(max(aux_id)+1, 0) from aux_users),
		current_user
	);
	return new;
end; $$ 
language plpgsql;

create or replace trigger users_regiao
before insert or update or delete on region
for each row execute function trigger_ex6();