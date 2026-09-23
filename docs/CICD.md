# CI/CD Android

## Pull Request
`pr-validation.yml` comprueba estructura y evita nombres de secretos privados en el cliente.

## Integración continua
`android-ci.yml` ejecuta tests unitarios, lint y `assembleDebug`. El APK debug se publica como artefacto; no es una release firmada.

## Seguridad
`codeql.yml` analiza Java en cambios de `main` y Pull Requests. Los secretos nunca se guardan en el repositorio.

## Release
`release-apk.yml` construye el APK release. La firma de producción debe añadirse después con un keystore guardado en GitHub Actions Secrets/Environment, nunca en el repositorio.

CI/CD no equivale a despliegue completo: la base Supabase y sus migraciones requieren una etapa separada con credenciales protegidas y revisión manual.

## Validaciones adicionales
- `supabase-validation.yml`: orden de migraciones, funciones requeridas y política de secretos.
- `dependency-review.yml`: bloquea dependencias nuevas con severidad alta en Pull Requests.
- `repository-hygiene.yml`: evita keystores, certificados, `local.properties` y artefactos generados.
- `android-manifest.yml`: valida recursos y manifest mediante Gradle.
