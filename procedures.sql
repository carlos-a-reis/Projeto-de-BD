# Stored Procedure para povoar a tabela Cliente #
delimiter $$
	create procedure sp_povoar_clientes(in qnt_clientes int)
    begin
		declare id int default 1;
        declare v_cpf char(11);
        declare v_email varchar(50);
        declare v_nome varchar(7) default 'cliente';
        declare v_sobrenome varchar(50);
        declare v_data_nascimento varchar(50);
        
        while id <= qnt_clientes do
			set v_cpf = lpad(floor(rand() * 100000000000), 11, '0');
            set v_sobrenome = cast(id as char);
            set v_email = concat(v_nome, '.', v_sobrenome, 'email.com');
            set v_data_nascimento = date_add(curdate(), interval -floor(rand() * 365 * 80) day);
            
			insert into cliente(cpf, email, nome, sobrenome, data_nascimento)
            values(v_cpf, v_email, v_nome, v_sobrenome, v_data_nascimento);
            
            set id = id + 1;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar a tabela Categoria #
delimiter $$
	create procedure sp_povoar_categorias(in qnt_categorias int)
    begin
		declare id int default 1;
        declare v_nome varchar(50);
        declare v_descricao varchar(100);
        
        while id <= qnt_categorias do
            set v_nome = concat('categoria - ', cast(id as char));
            set v_descricao = concat('Descrição detalhada da categoria: ', v_nome);
            
			insert into categoria(nome, descricao)
            values(v_nome, v_descricao);
            
            set id = id + 1;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar a tabela Endereço #
delimiter $$
	create procedure sp_povoar_enderecos(in qnt_enderecos int)
    begin
		declare id int default 1;
        declare v_cep char(8);
        declare v_rua varchar(50);
        declare v_bairro varchar(50);
        declare max_cliente_id int;
        declare min_cliente_id int;
        declare v_id_cliente int;
        
        select max(id_cliente), min(id_cliente) into max_cliente_id, min_cliente_id from cliente;
        
        while id <= qnt_enderecos do
            set v_cep = lpad(floor(rand() * 100000000), 8, '0');
            set v_rua = concat('Rua ', id);
            set v_bairro = concat('Bairro ', id);
            set v_id_cliente = floor(min_cliente_id + (rand() * (max_cliente_id - min_cliente_id + 1)));
            
			insert into endereco(numero, cep, rua, bairro, id_cliente)
            values(id, v_cep, v_rua, v_bairro, v_id_cliente);
            
            set id = id + 1;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar a tabela Pedido #
delimiter $$
	create procedure sp_povoar_pedidos(in qnt_pedidos int)
    begin
		declare id int default 1;
        declare v_data_pedido date;
        declare v_data_entrega date;
        declare v_status enum('Pendente', 'Aprovado', 'Preparando', 'Enviado', 'Recebido');
        declare max_cliente_id int;
        declare min_cliente_id int;
        declare v_id_cliente int;
        
        select max(id_cliente), min(id_cliente) into max_cliente_id, min_cliente_id from cliente;
        
        while id <= qnt_pedidos do
            set v_data_pedido = date_add(curdate(), interval -floor(rand() * 365 * 3) day);
            set v_data_entrega = date_add(curdate(), interval +floor(rand() * 70) day);
            set v_status = elt(floor(1 + (rand() * 5)), 'Pendente', 'Aprovado', 'Preparando', 'Enviado', 'Recebido');
            set v_id_cliente = floor(min_cliente_id + (rand() * (max_cliente_id - min_cliente_id + 1)));
            
			insert into pedido(data_pedido, data_entrega, status, id_cliente)
            values(v_data_pedido, v_data_entrega, v_status, v_id_cliente);
            
            set id = id + 1;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar a tabela Produto #
delimiter $$
	create procedure sp_povoar_produtos(in qnt_produtos int)
    begin
		declare id int default 1;
        declare v_nome varchar(20);
        declare v_descricao varchar(100);
        declare v_preco decimal(10,2);
        declare v_estoque int;
        declare v_disponivel tinyint;
        declare max_categoria_id int;
        declare min_categoria_id int;
        declare v_id_categoria int;
        
        select max(id_categoria), min(id_categoria) into max_categoria_id, min_categoria_id from categoria;
        
        while id <= qnt_produtos do
			set v_nome = concat('Produto - ', cast(id as char));
            set v_descricao = concat('Descrição detalhada do produto: ', v_nome);
            set v_preco = round(10 + (rand() * 1000), 2);
            set v_estoque = floor(rand() * 100);
            set v_disponivel = floor(rand() * v_estoque);
            set v_id_categoria = floor(min_categoria_id + (rand() * (max_categoria_id - min_categoria_id + 1)));
            
			insert into produto(nome, descricao, preco, estoque, disponivel, id_categoria)
            values(v_nome, v_descricao, v_preco, v_estoque, v_disponivel, v_id_categoria);
            
            set id = id + 1;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar a tabela Itens_Pedido #
delimiter $$
	create procedure sp_povoar_itens_pedidos(in qnt_itens_pedidos int)
    begin
		declare id int default 1;
        declare v_quantidade int;
        declare max_produto_id int;
        declare min_produto_id int;
        declare v_id_produto int;
        declare max_pedido_id int;
        declare min_pedido_id int;
        declare v_id_pedido int;
        declare item_existe int;
        
        select max(id_produto), min(id_produto) into max_produto_id, min_produto_id from produto;
        select max(id_pedido), min(id_pedido) into max_pedido_id, min_pedido_id from pedido;
        
        while id <= qnt_itens_pedidos do
            set v_quantidade = floor(rand() * 100);
            set v_id_produto = floor(min_produto_id + (rand() * (max_produto_id - min_produto_id + 1)));
            set v_id_pedido = floor(min_pedido_id + (rand() * (max_pedido_id - min_pedido_id + 1)));
             
			select count(*) into item_existe from itens_pedido
			where id_produto = v_id_produto and id_pedido = v_id_pedido;
        
			if item_existe = 0 then
				insert into itens_pedido(id_produto, id_pedido, quantidade)
				values(v_id_produto, v_id_pedido, v_quantidade);
            
				set id = id + 1;
			end if;
		end while;
	end$$
delimiter ;


# Store Procedure para povoar todas as tabelas do banco de dados #
delimiter $$
	create procedure sp_povoar_banco_de_dados(in qnt_registros int)
    begin
		call sp_povoar_clientes(qnt_registros);
        call sp_povoar_categorias(qnt_registros);
        call sp_povoar_enderecos(qnt_registros);
        call sp_povoar_pedidos(qnt_registros);
        call sp_povoar_produtos(qnt_registros);
        call sp_povoar_itens_pedidos(qnt_registros);
	end$$
delimiter ;


# Store Procedure para limpar todas as tabelas do banco de dados #
delimiter $$
	create procedure sp_truncate_banco_de_dados()
    begin
		truncate table cliente;
        truncate table categoria;
        truncate table endereco;
        truncate table pedido;
        truncate table produto;
        truncate table itens_pedido;
	end$$
delimiter ;

call sp_truncate_banco_de_dados();
call sp_povoar_banco_de_dados(1000);

select * from cliente;