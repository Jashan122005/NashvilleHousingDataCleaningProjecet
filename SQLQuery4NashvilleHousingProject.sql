-- Cleaning data in sql

Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

--Standardise data Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

Update NashvilleHousingData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousingData
Add SaleDateConverted Date;

Update NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address Data
-- If two parcel IDs are same and if one address is given and other is 
--missing then we can populate or say they both have same Property Address
-- then both the rows are equal so combine them as one

Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData
--Where PropertyAddress is null so copy the address of b to a
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData a
JOIN NashvilleHousingDataProjecet.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null
-- Empty no value now

-- The empty values of Property address are updated by b and now address has values 
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData a
JOIN NashvilleHousingDataProjecet.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
	Where a.PropertyAddress is null


-- Breaking out address into Individual Columns (Address, City, State)

Select PropertyAddress
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
--CHARINDEX(',', PropertyAddress) as address is a number so -1 used to remove , at last
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address1
-- +1 for the next address1 varna uske aage bhi , aa jayega
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

--Ab alag toh krdiya city aur address ko toh 2 naye columns create bhi krne pdenge na
ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData
--Added at last

--Now for owneraddress but in easy way using parsename
Select OwnerAddress
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

Select 
-- PARSENAME(OwnerAddress, 1) -- useful for only periods('.') not ',' So
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3) -- work backwards so ulta karenge
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

--Change 0 and 1 to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant) , Count(SoldAsVacant)
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = '0' THEN 'Yes'
	   when SoldAsVacant = '1' THEN 'No'
	   ELSE CAST(SoldAsVacant AS NVARCHAR(10)) -- bit to string
	   END
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData

ALTER TABLE NashvilleHousingDataProjecet.dbo.NashvilleHousingData
ADD SoldAsVacantDescription NVARCHAR(10);

UPDATE NashvilleHousingDataProjecet.dbo.NashvilleHousingData
SET SoldAsVacantDescription = 
    CASE 
        WHEN SoldAsVacant = '0' THEN 'Yes'
        WHEN SoldAsVacant = '1' THEN 'No'
        ELSE NULL
    END;
	SELECT DISTINCT(SoldAsVacantDescription), COUNT(SoldAsVacantDescription)
FROM NashvilleHousingDataProjecet.dbo.NashvilleHousingData
GROUP BY SoldAsVacantDescription
ORDER BY 2;

--Remove Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID ) row_num
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData
--Order by ParcelID
)
-- Tells all the duplicate data
Select *
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

Delete 
FROM RowNumCTE
Where row_num > 1
--Deleted the copied dat 104 rows
Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData


--Delete Unused Columns

Select *
From NashvilleHousingDataProjecet.dbo.NashvilleHousingData
ALTER TABLE NashvilleHousingDataProjecet.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress
ALTER TABLE NashvilleHousingDataProjecet.dbo.NashvilleHousingData
DROP COLUMN SaleDate