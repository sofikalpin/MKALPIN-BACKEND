# Usar la imagen oficial de Node.js
FROM node:18-alpine

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Crear directorio de trabajo
WORKDIR /app

# Cambiar propiedad del directorio de trabajo
RUN chown -R nextjs:nodejs /app
USER nextjs

# Copiar archivos de dependencias
COPY --chown=nextjs:nodejs package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar el código fuente
COPY --chown=nextjs:nodejs . .

# Crear directorio para uploads si no existe
RUN mkdir -p uploads

# Crear directorio para archivos temporales
RUN mkdir -p /tmp

# Exponer el puerto (usando variable de entorno)
EXPOSE ${PORT:-5000}

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "const http=require('http');const req=http.request({hostname:'localhost',port:process.env.PORT||5000,path:'/'},res=>{process.exit(res.statusCode===200?0:1)});req.on('error',()=>process.exit(1));req.end();"

# Comando para ejecutar la aplicación
CMD ["npm", "start"]
