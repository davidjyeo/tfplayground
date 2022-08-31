$locName = "UK South"
Get-AzVMImagePublisher -Location $locName | Select-Object PublisherName

$pubName = "AlmaLinux"
Get-AzVMImageOffer -Location $locName -PublisherName $pubName | Select-Object Offer

$offerName="AlmaLinux"
Get-AzVMImageSku -Location $locName -PublisherName $pubName -Offer $offerName | Select-Object Skus

$skuName="<SKU>"
Get-AzVMImage -Location $locName -PublisherName $pubName -Offer $offerName -Sku $skuName | Select-Object Version