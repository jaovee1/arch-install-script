#!/bin/bash

# Instalacao manual do "Arch Linux 2025.11.01"
# baseado na wiki oficial da distribuicao,
# pensado em um notebook medio de 2024.

# Requisitos utilizados como exemplo:

# - Rede Wi-Fi com SSID oculto, para baixar os pacotes
# - Armazemaneto SSD do tipo NVMe de 256GB
# - Gerenciador de incialização GRUB

# Observacao: Voce pode alterar os parametros,
# de acordo com suas especificacoes :)

# Passo 1: Configurar teclado brasileiro.
loadkeys br-abnt2

# Passo 2: Fonte maior para monitores Full HD.
setfont ter-132b

# Passo 3: Descomentar localizacao "pt_BR" na linha "391".
sed -i '391s/^.//' /etc/locale.gen

# Passo 4: Gerar configuracoes de localizacao.
locale-gen

# Passo 5: Conectar Wi-Fi oculto com senha.
# Observacao: Neste caso, preencha suas informacoes pessoais entre os colchetes.
iwctl --passphrase [sua-senha] station [sua-antena] connect-hidden [seu-wifi]

# Passo 6: Configurar armazenamento para GPT e criar 3 particoes (efi, swap e root).
# Observacao: O tipo de tabela de particao, depende do ano do seu computador,
# antes de 2010, e comum MBR/LEGACY (legado), apos 2010, e comum GPT/UEFI.
echo -e ',1G,U\n,4G,S\n,+,\n' | sfdisk /dev/nvme0n1 --label gpt

# Passo 7: Formatar particao EFI (para FAT32).
mkfs.fat -F 32 /dev/nvme0n1p1

# Passo 8: Formatar particao SWAP.
mkswap /dev/nvme0n1p2

# Passo 9: Formatar particao ROOT.
echo 'y' | mkfs.ext4 /dev/nvme0n1p3

# Passo 10: Montar particao ROOT (raiz do sistema Linux).
mount /dev/nvme0n1p3 /mnt

# Passo 11: Montar particao UEFI (inicializacao do sistema).
mount --mkdir /dev/nvme0n1p1 /mnt/efi

# Passo 12: Habilitar memoria SWAP.
swapon /dev/nvme0n1p2

# Passo 13: Gerar arquivo "vconsole.conf" para evitar erros,
# relacionados a fonte persistente.
touch /etc/vconsole.conf 

# Passo 14: Instalar pacotes essenciais do Linux.
pacstrap -K /mnt base linux linux-firmware

# Passo 14: Criar sistema de arquivos.
genfstab -U /mnt >> /mnt/etc/fstab

# Passo 15: Mudar para a raiz do sistema novo a ser configurado.
arch-chroot /mnt

# Passo 16: Configurar fuso horario (Sao Paulo).
ln -sf /usr/share/zoneinfo/Brazil/East /etc/localtime

# Passo 17: Configurar o relogio em tempo real no sistema.
hwclock --systohc

# Passo 18: Descomentar localizacao "pt_BR" na linha "391".
sed -i '391s/^.//' /etc/locale.gen

# Passo 19: Gerar configurações de localizacao.
locale-gen

# Passo 20: Configurar nome do hospede (Host).
echo PC-JOOJ > /etc/hostname

# Passo 21: Configurar senha ROOT (administrador).
passwd

# Passo 22: Instalar o gerenciador de inicializacao (GRUB).
echo 'Y' | pacman -S grub efibootmgr

# Passo 23: Instalar GRUB na particao EFI
# Observacao: Na opcao "--bootloader-id",
# voce pode personalizar o nome de inicializacao do GRUB.
grub-install --target=x86_64-efi --efi-directory=efi --bootloader-id=GRUB

# Passo 24: Criar arquivo de configuracao do GRUB.
grub-mkconfig -o /boot/grub/grub.cfg

# Passo 25: Instalacao de pacotes adicionais
# (editor de texto VIM e conexao de rede sem fio).
echo 'Y' | pacman -S vim iwd

# Nota final:
# Com todas essas configuracoes, ja e possivel ter autonomia
# para configurar o restante via linha de comando,
# futuramente, pretendo inserir condicionais, opcoes e entrada de valores,
# mas para essa primeira versao, fico muito orgulhoso de conseguir
# instalar o Arch Linux na unha! :')