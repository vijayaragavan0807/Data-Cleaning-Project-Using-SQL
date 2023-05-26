/*
Cleaning data in SQL Queries 
*/
SELECT *
FROM ppp.dbo.NashvilleHousingData1

-------------------------------------------------------------

--Populate Property Address data


SELECT a.uniqueID,b.uniqueID,a.parcelID,b.parcelID,a.propertyaddress,b.propertyaddress,isnull(a.propertyaddress,b.propertyaddress)
FROM ppp.dbo.NashvilleHousingData1 a
JOIN ppp.dbo.NashvilleHousingData1 b
ON a.parcelID = b.parcelID
AND a.uniqueID<>b.uniqueID
WHERE a.propertyaddress is null


UPDATE a 
SET propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
FROM ppp.dbo.NashvilleHousingData1 a
JOIN ppp.dbo.NashvilleHousingData1 b
ON a.parcelID = b.parcelID
AND a.uniqueID<>b.uniqueID
WHERE a.propertyaddress is null


--------------------------------------------------------------

--Breaking Out Address into Individual Columns(Address,City,State)



SELECT PropertyAddress,SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM ppp.dbo.NashvilleHousingData1

ALTER TABLE ppp.dbo.NashvilleHousingData1
ADD PropertySplitAddress Nvarchar(255);

UPDATE ppp.dbo.NashvilleHousingData1
SET PropertySplitAddress= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE ppp.dbo.NashvilleHousingData1
ADD PropertySplitCity Nvarchar(255);

UPDATE ppp.dbo.NashvilleHousingData1
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


------------------------------------------------------------------------

SELECT owneraddress,parsename((replace(owneraddress,',','.')),1),
parsename((replace(owneraddress,',','.')),2),
parsename((replace(owneraddress,',','.')),3)
FROM  ppp.dbo.NashvilleHousingData1




ALTER TABLE ppp.dbo.NashvilleHousingData1
ADD OwnerSplitAddress Nvarchar(255);

UPDATE ppp.dbo.NashvilleHousingData1
SET OwnerSplitAddress= parsename((replace(owneraddress,',','.')),3)


ALTER TABLE ppp.dbo.NashvilleHousingData1
ADD OwnerSplitCity Nvarchar(255);

UPDATE ppp.dbo.NashvilleHousingData1
SET OwnerSplitCity= parsename((replace(owneraddress,',','.')),2)



ALTER TABLE ppp.dbo.NashvilleHousingData1
ADD OwnerSplitState Nvarchar(255);

UPDATE ppp.dbo.NashvilleHousingData1
SET OwnerSplitState= parsename((replace(owneraddress,',','.')),1)


-------------------------------------------------------------------

--Change N and Y to Yes and No in "Sold as Vacant" field



SELECT SoldAsVacant,
CASE
WHEN SoldAsVacant='N' THEN 'No'
WHEN SoldAsVacant='Y'THEN 'Yes' 
END AS SoldAsVacant
FROM ppp.dbo.NashvilleHousingData1


select soldasvacant,count(*)
from ppp.dbo.NashvilleHousingData1
group by soldasvacant



UPDATE ppp.dbo.NashvilleHousingData1
SET SoldAsVacant =CASE
WHEN SoldAsVacant='N' THEN 'No' 
WHEN SoldAsVacant='Y' THEN 'Yes'
ELSE SoldAsVacant 
END

---------------------------------------------------------------

 --Remove Duplicates

 WITH temp1 as 
(
 SELECT *,
 ROW_NUMBER() OVER (PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference ORDER BY uniqueID) as row_num
 FROM  ppp.dbo.NashvilleHousingData1
 )
 DELETE
 FROM  temp1
 WHERE row_num>1





 -------------------------------------------------------

 --Delete Unused Columns

 ALTER TABLE ppp.dbo.NashvilleHousingData1
 DROP COLUMN OwnerAddress,TaxDistrict, PropertyAddress, SaleDate


 


 