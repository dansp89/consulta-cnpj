# Consulta de CNPJ

Sistema de consulta de CONSULTA de CNPJ, estes dados são todos abertos

## Recursos da API

1. Todos os campos são consultáveis
1. Paginação com filtros
1. Consulta individual
1. Consulta por multifiltros de diversas combinações
1. Consultas por cnaes e afins

## Exemplo de Layouts

Exemplos de SQL e resultado de consulta

## para consultas Individuais

````sql
-- Consulta Individual: By: DanSP89
SELECT
    jsonb_build_object(
        'cnpj', estabelecimento.cnpj,
        'abertura', estabelecimento.data_inicio_atividades,
        'situacao', estabelecimento.situacao_cadastral,
        'tipo', 'Empresarial',
        'razão social', empresas.razao_social,
        'nome fantasia', estabelecimento.nome_fantasia,
        'porte', empresas.porte_empresa,
        'natureza_juridica', jsonb_build_object(
            'codigo', natureza_juridica.codigo,
            'descricao', natureza_juridica.descricao
        ),
        'atividade_principal', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'codigo', cnae_principal.codigo,
                    'text', cnae_principal.descricao
                )
            )
            FROM cnae AS cnae_principal
            WHERE estabelecimento.cnae_fiscal = cnae_principal.codigo
        ),
        'atividades_secundarias', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'codigo', cnae_secundaria.codigo,
                    'text', cnae_secundaria.descricao
                )
            )
            FROM cnae AS cnae_secundaria
            WHERE estabelecimento.cnae_fiscal_secundaria LIKE '%' || cnae_secundaria.codigo || '%'
        ),
        'logradouro', estabelecimento.logradouro,
        'numero', estabelecimento.numero,
        'municipio', jsonb_build_object(
            'codigo', municipio.codigo,
            'descricao', municipio.descricao
        ),
        'bairro', estabelecimento.bairro,
        'uf', estabelecimento.uf,
        'cep', estabelecimento.cep,
        'email', estabelecimento.correio_eletronico,
        'telefone', estabelecimento.ddd1 || estabelecimento.telefone1,
        'telefone2', estabelecimento.ddd2 || estabelecimento.telefone2,
        'data_situacao', estabelecimento.data_situacao_cadastral,
        'ultima_atualizacao', estabelecimento.data_situacao_cadastral,
        'status', 'OK',
        'motivo_situacao', jsonb_build_object(
            'code', motivo.codigo,
            'text', motivo.descricao
        ),
        'situacao_especial', estabelecimento.situacao_especial,
        'data_situacao_especial', estabelecimento.data_situacao_especial,
        'capital_social', empresas.capital_social,
        'qsa', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'code', qualificacao_socio.codigo,
                    'text', qualificacao_socio.descricao
                )
            )
            FROM socios
            LEFT JOIN qualificacao_socio ON socios.qualificacao_socio = qualificacao_socio.codigo
            WHERE estabelecimento.cnpj = socios.cnpj
        ),
        'extra', jsonb_build_object(),
        'billing', jsonb_build_object(
            'free', true,
            'database', true
        )
    ) AS json_data
FROM
    estabelecimento
LEFT JOIN
    empresas ON estabelecimento.cnpj_basico = empresas.cnpj_basico
LEFT JOIN
    municipio ON estabelecimento.municipio = municipio.codigo
LEFT JOIN
    motivo ON estabelecimento.motivo_situacao_cadastral = motivo.codigo
LEFT JOIN
    natureza_juridica ON empresas.natureza_juridica = natureza_juridica.codigo
WHERE
    estabelecimento.cnpj_basico = '32444586' -- Exemplo de CNPJ BASE para consulta
LIMIT 1;
``

### Resposta da consulta individual
```json
{
  "uf": "PR",
  "cep": "85020350",
  "qsa": null,
  "cnpj": "32444586000170",
  "tipo": "Empresarial",
  "email": "carlos@henriqueartdesign.com.br",
  "extra": {},
  "porte": "01",
  "bairro": "BOQUEIRAO",
  "numero": "203",
  "status": "OK",
  "billing": {
    "free": true,
    "database": true
  },
  "abertura": "20190114",
  "situacao": "02",
  "telefone": "4298686668",
  "municipio": {
    "codigo": "7583",
    "descricao": "GUARAPUAVA"
  },
  "telefone2": "",
  "logradouro": "RODRIGUES ALVES",
  "data_situacao": "20190114",
  "nome fantasia": "HAD SOLUCOES EM TECNOLOGIA E HOSPEDAGEM",
  "razão social": "CARLOS HENRIQUE BRITO SANTOS",
  "capital_social": 25000,
  "motivo_situacao": {
    "code": "00",
    "text": "SEM MOTIVO"
  },
  "natureza_juridica": {
    "codigo": "2135",
    "descricao": "Empresário (Individual)"
  },
  "situacao_especial": "",
  "ultima_atualizacao": "20190114",
  "atividade_principal": [
    {
      "text": "Tratamento de dados, provedores de serviços de aplicação e serviços de hospedagem na internet",
      "codigo": "6311900"
    }
  ],
  "atividades_secundarias": [
    {
      "text": "Web design",
      "codigo": "6201502"
    },
    {
      "text": "Suporte técnico, manutenção e outros serviços em tecnologia da informação",
      "codigo": "6209100"
    },
    {
      "text": "Marketing direto",
      "codigo": "7319003"
    },
    {
      "text": "Atividades de produção de fotografias, exceto aérea e submarina",
      "codigo": "7420001"
    }
  ],
  "data_situacao_especial": ""
}
````
