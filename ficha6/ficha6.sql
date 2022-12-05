-- 1
-- Desenvolva um programa em PLpgSQL que imprima no ecrã a hora atual, 
-- espere 20 segundos, e volte a imprimir a hora atual.

do $$
declare
   curr_date_time timestamp;
begin 
   select CURRENT_TIMESTAMP into curr_date_time;
   raise notice 'Current date & time: %', curr_date_time;
end; $$

-- 2
-- Desenvolva um programa em PLpgSQL que imprima a tabuada do número 5 no ecrã.

do $$
declare
   max_n integer:= 10;
   tabuada_n integer := 5;
   counter integer := 0 ; 
   result_n integer;
begin
	loop 
		exit when counter = max_n ; 
		counter := counter + 1 ; 
		result_n := counter * tabuada_n;
		raise notice '% x % = %', counter, tabuada_n, result_n; 
	end loop; 
end; $$

-- 3
-- Desenvolva um programa em PLpgSQL que imprima no ecrã a tabuada completa.

do $$
declare
   max_n integer:= 10;
   tabuada_n integer := 0;
   counter integer := 0 ; 
   result_n integer;
begin
	loop
		exit when tabuada_n = max_n ; 
		tabuada_n := tabuada_n + 1;
		counter := 0;
		loop 
			exit when counter = max_n ; 
			counter := counter + 1 ; 
			result_n := counter * tabuada_n;
			raise notice '% x % = %', counter, tabuada_n, result_n; 
		end loop; 
	end loop;
end; $$

-- 4
-- Desenvolva um programa em PLpgSQL que imprima no ecrã o número total de clientes
-- (customer) na base de dados

do $$
declare
   customer_count integer;
begin 
   select count(c_custkey) into customer_count
   from customer;
   raise notice 'Customer count: %', customer_count;
end; $$

-- 5
-- Desenvolva um programa em PLpgSQL que imprima no ecrã o nome do cliente que tem o id 
-- número 10

do $$
declare
	nome_cliente varchar;
begin
	select c_name into nome_cliente from customer where c_custkey = 10;
	raise notice '%', nome_cliente;
end; $$

-- 6
-- Desenvolva um programa em PLpgSQL que imprima no ecrã:
--  • Na primeira linha o nome do cliente que realizou a ordem com o valor mais baixo;
--  • Na segunda linha o nome do cliente que realizou a ordem com o valor mais alto;
--  • Na terceira linha o nome e número do telefone do cliente que realizou a ordem com o valor baixo;

do $$
declare
	client_lowest_order customer%rowtype;
	client_highest_order customer%rowtype;
begin 
	select * into client_lowest_order
	from customer where c_custkey = (
	select o_custkey from orders where o_totalprice = (
			select min(o_totalprice) from orders
		)
	);
	select * into client_highest_order
	from customer where c_custkey = (
	select o_custkey from orders where o_totalprice = (
			select max(o_totalprice) from orders
		)
	);
	
	raise notice '1 - %', client_lowest_order.c_name;
	raise notice '2 - %', client_highest_order.c_name;
	raise notice '3 - %, %', client_lowest_order.c_name, client_lowest_order.c_phone;

end; $$

-- 7
-- Usando a linguagem SQL, crie a seguinte tabela:
-- temp(col1 number(10),col2 number(20),message varchar2(100))

create table temp(
	col1 numeric(10),
	col2 numeric(20),
	message varchar(100)
)

-- 8
-- Faça um programa PLpgSQL que insira 100 registos na tabela temp com os seguintes dados
-- (utilize o ciclo for):
--   COL1    COL2    MESSAGE
--  ------- ------- --------------------
--   1       100     Col1 é impar
--   2       200     Col1 é par
--   3       300     Col1 é impar
--   ...     ...     ...
--   100     10000   Col1 é par

do $$
begin
	for counter in 1..100 loop
		if (counter % 2) = 0 then
			insert into temp (col1, col2, message) values (counter, counter*100, 'Col1 é par');
		else 
			insert into temp (col1, col2, message) values (counter, counter*100, 'Col1 é impar');
		end if;
   	end loop;
end; $$

-- 9
-- Repita o exercício anterior, utilizando o ciclo while

do $$
declare
	counter integer := 0;
begin
	while counter < 100 loop
		counter := counter + 1;
		if (counter % 2) = 0 then
			insert into temp (col1, col2, message) values (counter, counter*100, 'Col1 é par');
		else 
			insert into temp (col1, col2, message) values (counter, counter*100, 'Col1 é impar');
		end if;
   	end loop;
end; $$

-- 10
-- Realize um programa em PLpgSQL que pesquise pelo cliente “Filipe Sá” e imprima no ecrã o 
-- seu número de telemóvel. Se não encontrar, imprima no ecrã o erro “cliente Filipe Sá, não 
-- foi encontrado”

do $$
declare
	cliente customer%rowtype;
	nome customer.c_name%type := 'Filipe Sá';
begin  

	select * from customer
	into cliente
	where c_name like ('%'|| nome || '%');

	if not found then
		raise notice 'O cliente % não foi encontrado', nome;
	else
		raise notice 'Nº de tlm de %: %', nome, cliente.c_phone;
	end if;
end $$

-- 11
-- Repita o exercício anterior, no entanto se não encontrar o cliente “Filipe Sá”, introduza o 
-- mesmo na base de dados. Nota considere que o fornecedor, pertence ao país “BRAZIL”, 
-- Obtenha a chave primaria do País “brasil” no seu programa PLpgSQL.

do $$
declare
	cliente customer%rowtype;
	nome customer.c_name%type := 'Filipe Sá';
begin  

	select * from customer
	into cliente
	where c_name like ('%'|| nome || '%');

	if not found then
		raise notice 'O cliente % não foi encontrado. Vai ser criado!', nome;
        insert into 
			customer (c_custkey, c_name, c_address, c_nationkey, c_phone, c_acctbal, c_mktsegment, c_comment)
		values (
			(select (max(c_custkey) + 1) from customer),
			'Filipe Sá',
			'Rua das Avenidas',
			(select n_nationkey from nation where upper(n_name) like '%BRAZIL%'),
			'12-345-678-9012',
			123.45,
			'BUILDING',
			'lorem ipsum'
		);
	else
		raise notice 'Nº de tlm de %: %', nome, cliente.c_phone;
	end if;
end $$

-- 12
-- Elabora um programa em PLpgSQL que imprima no ecrã todos os dados do fornecedor
-- numero 10.

do $$
declare
	s record;
begin
	select * into s from supplier where s_suppkey = 10;
	raise notice '% % % % % % %', s.s_suppkey, s.s_name, s.s_address, s.s_nationkey, s.s_phone, s.s_acctbal, s.s_comment;
end; $$

-- 13
-- Repita o resultado, mas agora imprima no ecrã o resultado de todos os fornecedores.

do $$
declare
	s record;
begin
	select * into s from supplier where s_suppkey = 10;
	raise notice '% % % % % % %', s.s_suppkey, s.s_name, s.s_address, s.s_nationkey, s.s_phone, s.s_acctbal, s.s_comment;
	
	for s in select * from supplier
	loop
		raise notice '% % % % % % %', s.s_suppkey, s.s_name, s.s_address, s.s_nationkey, s.s_phone, s.s_acctbal, s.s_comment;
	end loop;
end; $$

-- 14
-- Elabore um programa em PLpgSQL que imprima no ecrã, na mesma linha, a chave primaria 
-- e o nome do País com o n_nationkey igual a 1. Neste mesmo programa, crie duas exceções.
-- Exceção 1 - A query vai devolver mais que um resultado;
-- Exceção 2 - A query não devolve nenhum resultado.

do $$
declare
	nation record;
	counter integer;
begin
	select * into nation from nation where n_nationkey = 1;
	select count(n_nationkey) into counter from nation where n_nationkey = 1;
	
	if counter = 1 then
		raise notice '% % %', nation.n_nationkey, nation.n_name;
	elsif counter = 0 then
		raise notice 'No records found';
	elsif counter > 1 then
		raise notice 'More than one records found';
	end if;
	
end; $$

-- 15
-- Crie um procedimento que receba dois números e imprima a tabuada, do primeiro até ao 
-- último. Exemplo da chamada do procedimento CALL tabuada(3,9); No final deve apagar o 
-- procedimento.
-- Exemplo: Número um 3, número dois 9 resultados: [3x1=3, 3X2=6, … ,3x10=20] …. [9x1=9, 
-- … 9x10=90]

create or replace procedure tabuada(
   num1 integer,
   num2 integer
)
language plpgsql    
as $$
declare
	result_n integer;
begin
	for i in num1..num2 loop
		for j in 1..10 loop
			result_n := i * j;
			raise notice '% x % = %', i, j, result_n; 
		end loop; 
	end loop;
end;$$

-- noutra query
call tabuada(3,6);

-- 16
-- Crie um procedimento que receba o código de um cliente e a partir desde dado imprima o 
-- seu nome e telefone. No final teste e apague o procedimento.

create or replace procedure cliente_nome_telefone(
   custkey integer
)
language plpgsql    
as $$
declare
	cliente record;
begin
	select * into cliente from customer where c_custkey = custkey;
	
	if not found then
		raise notice 'Cliente não encontrado';
	else
		raise notice 'Nome: % Tlm: %', cliente.c_name, cliente.c_phone;
	end if;
	
end;$$

-- noutra query
call cliente_nome_telefone(3);

-- 17
-- Elabore um procedimento em PLpgSQL que introduza um novo Pais. O procedimento deve 
-- receber o nome do País por argumento. Exemplo da chamada do procedimento CALL 
-- insereNation('CHILE'); No final deve apagar o procedimento

create or replace procedure inserirNation(
   nome varchar
)
language plpgsql    
as $$
begin

	
	if nome = '' then
		raise notice 'O nome nao pode estar vazio, o pais nao vai ser inserido';
	else
		insert into nation(
			n_nationkey,
			n_name,
			n_regionkey,
			n_comment
		) values (
			(select (max(n_nationkey)+1) from nation),
			nome,
			(select max(r_regionkey) from region),
			'lorem ipsum'
		);
		raise notice 'País criado!';
	end if;
	
end;$$

-- noutra query
call inserirNation('SPAIN');