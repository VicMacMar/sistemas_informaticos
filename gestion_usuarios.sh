#!/bin/bash

DEP_FILE="departamentos.csv"
USR_FILE="usuarios.csv"

case "$1" in
crear)

# Crear grupos
while IFS=, read -r grupo descripcion
do
  if ! getent group "$grupo" >/dev/null; then
    groupadd "$grupo"
  fi
done < <(tail -n +2 "$DEP_FILE")

# Crear usuarios
while IFS=, read -r login nombre desc grupo pass
do
  if ! id "$login" >/dev/null 2>&1; then
    useradd -m -c "$nombre - $desc" -G "$grupo" "$login"
    echo "$login:$pass" | chpasswd
    passwd -e "$login"
  fi
done < <(tail -n +2 "$USR_FILE")
;;

borrar)

# Borrar usuarios
while IFS=, read -r login nombre desc grupo pass
do
  userdel -r "$login" 2>/dev/null
done < <(tail -n +2 "$USR_FILE")

# Borrar grupos
while IFS=, read -r grupo descripcion
do
  groupdel "$grupo" 2>/dev/null
done < <(tail -n +2 "$DEP_FILE")
;;

*)
echo "Uso: $0 {crear|borrar}"
;;
esac
