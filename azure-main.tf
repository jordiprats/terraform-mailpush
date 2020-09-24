provider "azurerm" {
    version = "~>2.0"
    features {}
}

resource "azurerm_resource_group" "mailpushrg" {
    name     = "mailpushrg"
    location = "westeurope"

    tags = {
        environment = "mailpush"
    }
}

resource "azurerm_virtual_network" "mailpushnet" {
    name                = "mailpush_net"
    address_space       = ["10.0.0.0/8"]
    location            = azurerm_resource_group.mailpushrg.location
    resource_group_name = azurerm_resource_group.mailpushrg.name

    tags = {
        environment = "mailpush"
    }
}

resource "azurerm_subnet" "mailpushapinet" {
    name                 = "api_net"
    resource_group_name  = azurerm_resource_group.mailpushrg.name
    virtual_network_name = azurerm_virtual_network.mailpushnet.name
    address_prefixes       = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "api_IP" {
    name                         = "API_endpoint"
    location                     = azurerm_resource_group.mailpushrg.location
    resource_group_name          = azurerm_resource_group.mailpushrg.name
    allocation_method            = "Static"

    tags = {
        environment = "mailpush"
    }
}

resource "azurerm_network_security_group" "API_SG" {
    name                = "public_API_endpoint_SG"
    location            = azurerm_resource_group.mailpushrg.location
    resource_group_name = azurerm_resource_group.mailpushrg.name

    tags = {
        environment = "mailpush"
    }
}

resource "azurerm_network_security_rule" "API_http" {
    name                        = "allow_HTTP"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.mailpushrg.name
    network_security_group_name = azurerm_network_security_group.API_SG.name
}

resource "azurerm_network_security_rule" "API_https" {
    name                        = "allow_HTTPS"
    priority                    = 101
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.mailpushrg.name
    network_security_group_name = azurerm_network_security_group.API_SG.name
}

