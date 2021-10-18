terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags = {
    environment = "prod"
    team        = "devops"
  }
}

# create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# create public ip

resource "azurerm_public_ip" "publicip" {
  name                = join(var.vm["name"], ["pi"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# create NSG
resource "azurerm_network_security_group" "nsg" {
  name                = join(var.vm["name"], ["nsg"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#create network interface

resource "azurerm_network_interface" "nic" {
  name                = join(var.vm["name"], ["ni"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = join(var.vm["name"], ["niconfig"])
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# create a linux vm
resource "azurerm_virtual_machine" "vm" {
  name                  = var.vm["name"]
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm["vm_size"]

  storage_os_disk {
    name              = join(var.vm["name"], ["osdisk"])
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = var.vm["name"]
    admin_username = var.vm["admin_username"]
    admin_password = var.vm["admin_password"]
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}


