# LoveCakes - Frontend

Interface de compra e venda de bolos artesanais.

## Tecnologias

- React 19.2.0
- TypeScript 5.6.3
- Vite 5.4.11
- TailwindCSS 3.4.14
- React Router DOM 7.9.3
- TanStack Query 5.90.2
- Axios 1.12.2
- Zustand 5.0.8
- React Hook Form 7.63.0
- Zod 4.1.11

## Estrutura do Projeto

```
src/
├── app/                    # Configuração da aplicação
│   ├── App.tsx            # Componente raiz
│   ├── providers.tsx      # Provedores de contexto
│   └── router.tsx         # Configuração de rotas
├── pages/                 # Páginas da aplicação
│   ├── Home/             # Página inicial
│   ├── NotFound/         # Página 404
│   └── layouts/          # Layouts compartilhados
├── domain/               # Domínios de negócio
├── core/                 # Componentes e utilitários globais
│   ├── components/       # Componentes reutilizáveis
│   ├── lib/             # Configurações de bibliotecas
│   ├── types/           # Tipos globais
│   └── utils/           # Funções utilitárias
└── assets/              # Recursos estáticos
    └── styles/          # Estilos globais
```

## Configuração

1. Instalar dependências:
```bash
npm install
```

2. Configurar variáveis de ambiente:
```bash
cp .env.example .env
```

3. Editar `.env` com as configurações corretas:
```
VITE_API_URL=http://localhost:3000
VITE_API_VERSION=v1
VITE_API_TIMEOUT=30000
```

## Desenvolvimento

```bash
npm run dev
```

Acesse: http://localhost:5173

## Build

```bash
npm run build
```

## Preview

```bash
npm run preview
```

## Lint

```bash
npm run lint
```

## Arquitetura

### API Client

O projeto utiliza dois clientes HTTP:

- `publicClient`: Para endpoints públicos (`/api/v1/external`)
- `authenticatedClient`: Para endpoints autenticados (`/api/v1/internal`)

### State Management

- **TanStack Query**: Para gerenciamento de estado do servidor
- **Zustand**: Para estado global da aplicação (quando necessário)
- **React Hook Form**: Para gerenciamento de formulários

### Roteamento

- React Router DOM com lazy loading de páginas
- Layouts hierárquicos para estrutura consistente
- Error boundaries para tratamento de erros

## Convenções

### Nomenclatura

- Componentes: PascalCase (`UserProfile`)
- Hooks: camelCase com prefixo `use` (`useUserProfile`)
- Arquivos: Seguir nome do componente/hook
- Diretórios de domínio: camelCase (`userManagement`)

### Estrutura de Componentes

```
ComponentName/
├── main.tsx      # Implementação
├── types.ts      # Tipos
├── variants.ts   # Estilos (se necessário)
└── index.ts      # Exports
```

### Imports

- Use alias `@/` para imports absolutos
- Organize imports: React, bibliotecas, internos, tipos

## Próximos Passos

1. Implementar autenticação
2. Criar domínio de produtos
3. Criar domínio de carrinho
4. Implementar catálogo de produtos
5. Implementar sistema de pedidos