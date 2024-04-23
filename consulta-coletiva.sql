-- Consulta Coletiva: By: DanSP89
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
LIMIT 1;
