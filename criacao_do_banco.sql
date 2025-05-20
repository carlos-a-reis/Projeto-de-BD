create schema ecommerce;
use ecommerce;

create table cliente (
	id_cliente int primary key auto_increment,
    cpf char(11) not null unique,
    email varchar(50) not null unique,
    nome varchar(50) not null,
    sobrenome varchar(50) not null,
    data_nascimento date
);

create table categoria (
	id_categoria int primary key auto_increment,
	nome varchar(50) not null,
	descricao varchar(300)
);

create table endereco (
	numero int not null,
    cep char(8) not null,
    rua varchar(50) not null,
    bairro varchar(50) not null,
    id_cliente int not null,
    
    primary key (numero, cep),
    constraint endereco_cliente
		foreign key (id_cliente) 
		references cliente(id_cliente) 
		on delete cascade
		on update cascade
);

create table produto (
	id_produto int primary key auto_increment,
    nome varchar(20) not null unique,
    descricao varchar(300),
    preco decimal(10,2) not null,
    estoque int default 0,
    disponivel boolean default true,
    id_categoria int not null,
    
    constraint produto_categoria
		foreign key (id_categoria) 
		references categoria(id_categoria)
		on delete cascade
		on update cascade
);

create table pedido (
	id_pedido int primary key auto_increment,
    data_pedido date default (current_date),
    data_entrega date,
    status enum('Pendente', 'Aprovado', 'Preparando', 'Enviado', 'Recebido') default 'Pendente',
    id_cliente int not null,
    
    constraint pedido_cliente
		foreign key(id_cliente)
		references cliente(id_cliente)
		on delete cascade
		on update cascade
);

create table itens_pedido (
	id_produto int,
    id_pedido int,
    quantidade int not null default 1,
    
    primary key(id_produto, id_pedido),
	constraint itens_produto
		foreign key(id_produto)
        references produto(id_produto)
		on delete cascade
		on update cascade,
    constraint itens_pedido
		foreign key(id_pedido)
        references pedido(id_pedido)
		on delete cascade
		on update cascade
);