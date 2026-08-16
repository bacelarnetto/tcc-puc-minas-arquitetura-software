# Roteiro — Vídeo de Apresentação Final (Etapa 2)

> Regra do regulamento (CA-2.7): vídeo curto, **máximo 5 minutos**, boa qualidade,
> dando dimensão **completa** do projeto, com **foco na arquitetura**. Vale 10 dos
> 50 pontos da Etapa 2 (o segundo maior item, atrás só de Evidências da avaliação).
>
> ✅ **Conteúdo do relatório completo:** a seção 4 (ATAM) agora tem os 6 cenários
> (RNF01–RNF06) com tabela completa e evidências; as seções 5 (Avaliação Crítica) e
> 6 (Conclusão) também já estão escritas. As falas abaixo já refletem o texto final do
> relatório, escolhendo o Cenário RNF04 como exemplo falado no bloco 8 por ser o mais
> rico em trade-off — os outros 5 cenários existem no relatório mesmo sem entrar na
> fala do vídeo (tempo de 5 min não permite detalhar os 6). Revise só se o conteúdo
> dessas seções mudar depois.

**Duração alvo: 5:00.** Fale no ritmo normal (~150 palavras/min) — o texto de cada
bloco já está dimensionado para o tempo indicado, não precisa correr.

---

## Estrutura geral (orçamento de tempo)

| Bloco | Tempo | Acumulado |
| --- | --- | --- |
| 1. Abertura | 0:15 | 0:15 |
| 2. Contexto e problema | 0:35 | 0:50 |
| 3. Objetivo e proposta (arquitetura de referência) | 0:25 | 1:15 |
| 4. Restrições e requisitos (resumo) | 0:10 | 1:25 |
| 5. Diagrama de Contexto | 0:30 | 1:55 |
| 6. Diagrama de Container | 0:45 | 2:40 |
| 7. Diagrama de Componentes + padrões | 0:35 | 3:15 |
| 8. Avaliação ATAM (cenários) | 0:45 | 4:00 |
| 9. Avaliação crítica (prós/contras) | 0:30 | 4:30 |
| 10. Conclusão e encerramento | 0:30 | 5:00 |

Se precisar cortar, corte primeiro do bloco 4 (requisitos) — os diagramas (5-7) e
a avaliação (8-9) são o que pesa mais na nota e no que a banca (professor) espera ver.

---

## 1. Abertura (0:15)

**Tela:** slide de título ou sua câmera.

> "Olá, meu nome é José Ribamar Bacelar Netto. Este é o projeto integrado da
> Especialização em Arquitetura de Software Distribuído: o **RelatoSeg**, uma
> arquitetura de referência para orquestração de agentes de IA via protocolo MCP,
> aplicada à geração automatizada de relatórios de análise de sinistros de seguros."

---

## 2. Contexto e problema (0:35)

**Tela:** trecho da Introdução no docsify (seção 1).

> "Seguradoras têm até 30 dias corridos, pela Circular SUSEP 621, para regular um
> sinistro após receber a documentação da segurada — sob pena de multa e juros. Hoje
> esse processo é manual: o regulador acessa vários sistemas separados — apólice,
> documentos, laudos periciais — para montar um parecer. Isso gera respostas lentas,
> inconsistência entre pareceres de reguladores diferentes, e dificulta rastrear quais
> evidências embasaram cada decisão. E o problema não é exclusivo de sinistros: outras
> áreas da seguradora enfrentam a mesma necessidade de cruzar dados heterogêneos, sem
> uma arquitetura compartilhada para isso."

---

## 3. Objetivo e proposta — arquitetura de referência (0:25)

**Tela:** seção "Objetivos" do relatório.

> "A proposta não é só automatizar sinistros: é uma **arquitetura distribuída de
> referência**, baseada na orquestração de agentes de IA via protocolo MCP, reutilizável
> por qualquer área de negócio da seguradora — basta implementar um novo MCP Server de
> domínio, sem alterar o MCP Host. Sinistros é a instância que demonstra essa arquitetura
> na prática."

---

## 4. Restrições e requisitos — resumo (0:10)

**Tela:** tabelas de Restrições e RF/RNF (rolar rápido, sem ler tudo).

> "Defini 5 restrições arquiteturais, 15 requisitos funcionais e 6 não funcionais —
> segurança, extensibilidade, desempenho, rastreabilidade e disponibilidade — base
> para a avaliação ATAM a seguir."

---

## 5. Diagrama de Contexto (0:30)

**Tela:** Figura 1 — Diagrama de Contexto (`doc/relatorio/diagramas/3.1-contexto.png`).

> "No diagrama de contexto, a segurada pode disparar a análise direto pelo app mobile
> ou web portal — entrada self-service — ou o regulador dispara via integração com o
> Workflow/BPM já existente. Em ambos os casos, a plataforma orquestra os agentes de IA,
> consulta apólice, sinistro e documentos, gera o parecer final e notifica ativamente:
> e-mail para regulador e corretor, push para a segurada."

---

## 6. Diagrama de Container (0:45)

**Tela:** Figura 2 — visão macro (`3.2-container-macro.png`), depois passar rápido
pelas Figuras 3, 4 e 5 (entrada, pipeline, notificação).

> "No nível de container, a plataforma tem 23 containers organizados em três fluxos.
> Primeiro, entrada e autenticação: Keycloak com dois realms — interno federado ao SSO
> corporativo, externo para a segurada — e um API Gateway único que aplica RBAC.
> Segundo, o pipeline em si: o Temporal orquestra cinco steps de forma durável, com
> retry automático e deduplicação nativa — Init Worker, MCP Host, Report Builder e
> Document Generator. O MCP Host é o coração da orquestração de agentes: ele chama o
> provedor de LLM e usa a Tools API — via protocolo MCP — para consultar apólice e
> sinistro no data warehouse. Terceiro, a notificação: o Notifier publica o resultado
> num tópico Pub/Sub, com duas subscriptions independentes — uma atualiza o status,
> outra dispara o aviso ativo por e-mail e push."

---

## 7. Diagrama de Componentes + padrões arquiteturais (0:35)

**Tela:** uma das Figuras 6-9 (ex. Figura 7 — MCP Host e Tools API) + trecho da lista
de padrões (seção 3.3, final).

> "No diagrama de componentes, o padrão guarda-chuva é a **arquitetura hexagonal**:
> nenhum componente de negócio depende diretamente de infraestrutura externa — tudo
> passa por uma porta e um adapter. Sobre essa base, apliquei CQRS na API de Sinistros,
> Publish-Subscribe na notificação, e Strategy para os canais de notificação — e-mail e
> push usando a mesma interface, trocáveis em tempo de execução."

---

## 8. Avaliação ATAM — cenários (0:45)

**Tela:** seção 4 do relatório — Cenário RNF04 (tabela ATAM + evidências) e a Nota sobre RNF04 na seção 2.3.

> "Um cenário revelador da avaliação ATAM é o de desempenho versus custo, ligado ao
> RNF04: a plataforma precisa responder em até 10 minutos com 50 solicitações
> concorrentes, mas cada chamada ao provedor de LLM custa por token — e um raciocínio
> mais longo melhora a qualidade do parecer, só que aumenta custo e latência juntos.
> Resolvo isso com o LLM Provider Adapter — troca de modelo por etapa sem alterar
> código, mais barato na extração, mais robusto só na consolidação final — e cache no
> Redis para reduzir contexto reenviado. Um ponto de atenção que registrei: a latência
> do próprio provedor de LLM está fora do controle da arquitetura, a mesma fronteira já
> assumida para disponibilidade no RNF03."

> ✅ *Já escrito no relatório: os 6 cenários (RNF01–RNF06) estão completos na seção 4,
> cada um com tabela ATAM + evidência textual + evidência em figura. O Cenário RNF04
> (desempenho/custo/latência de token) foi escolhido para a fala por ser o mais rico em
> trade-off, com nota de risco espelhada na seção 2.3 — mas qualquer um dos outros 5
> (ex. RNF01 segurança, RNF06 offline mobile) também sustentaria este bloco, se preferir
> trocar. RNF01, RNF05 e RNF06 agora têm diagrama de sequência dedicado (Figuras 10,
> 11 e 12 — `doc/uml/4.3-*.puml`), mostrando comportamento em execução em vez de só
> estrutura estática; se trocar o exemplo pra um desses, vale usar a figura de sequência
> na tela em vez do diagrama de container.*

---

## 9. Avaliação crítica — prós e contras (0:30)

**Tela:** seção 5 do relatório.

> "Entre os trade-offs assumidos: optei por não usar um BFF, já que hoje os canais têm
> necessidades de dados parecidas — mas o app mobile, por ser offline-first, é o
> candidato natural a exigir um BFF próprio no futuro, com o cuidado de não duplicar
> autenticação ou lógica de status já resolvidas em outras camadas. Revisei também,
> durante o trabalho, a persistência do MCP Host: inicialmente ele compartilhava banco
> com o Temporal Server, mas por ser um domínio diferente — configuração de agentes,
> com dado sensível como chave de API — corrigi para uma instância isolada, reforçando
> Database per Service por domínio de negócio, não só por conveniência técnica."

---

## 10. Conclusão e encerramento (0:30)

**Tela:** seção 6 do relatório, ou de volta à sua câmera.

> "Como conclusão, o RelatoSeg mostra que dá para propor uma arquitetura de referência
> orquestrada por agentes de IA via MCP, reutilizável entre áreas de negócio de uma
> seguradora — validada aqui no domínio de sinistros. Entre as três lições aprendidas, a
> mais central é declarar explicitamente as fronteiras de responsabilidade frente a
> dependências externas — como o provedor de LLM — em vez de prometer cobertura sobre o
> que a plataforma não controla. Como próximos passos, destaco evoluir o cluster GKE
> para multi-region e instrumentar observabilidade de custo de token por sinistro.
> Obrigado."

---

## Checklist de produção

- [ ] Gravar em tela cheia com o relatório aberto via docsify (`npx docsify-cli serve doc/relatorio -p 3000`) — dá zoom e navegação mais limpos que abrir o `.md` cru.
- [ ] Preparar os cortes de tela com antecedência (abrir as abas/seções antes de gravar) para não perder tempo navegando ao vivo.
- [ ] Testar áudio antes da gravação final — qualidade de áudio pesa mais que qualidade de vídeo na percepção de "boa qualidade" (CA-2.7).
- [ ] Cronometrar um ensaio completo — se passar de 5:00, cortar primeiro o bloco 4.
- [ ] Depois de gravado: subir em repositório público (ex. YouTube não-listado, Drive público) — o regulamento exige que o link fique acessível durante todo o período de avaliação — e colar o link no relatório técnico.
