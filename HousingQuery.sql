-- Cleaning data in SQl queries

Select*
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

--Standardise sale date

Select SaleDateConverted, CONVERT(date, SaleDate)
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
Set SaleDate = CONVERT(date, SaleDate)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add SalesDateConverted Date;

UPDATE [Nashville Housing Data for Data Cleaning]
Set SaleDateConverted = CONVERT(date, SaleDate)


--Populate propert address data

Select *
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]
where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning] b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL( a.PropertyAddress, b.PropertyAddress)
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning] a
JOIN portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning] b
  on a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

--Seperate address into individual colums (Address, City, State)

Select PropertyAddress
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))as Address
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitAddress NVARCHAR(255);

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)


ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add PropertySplitCity NVARCHAR(255);

Update [Nashville Housing Data for Data Cleaning]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

Select *
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

SELECT OwnerAddress
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitAddress NVARCHAR(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 3)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitCity NVARCHAR(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 2)

ALTER TABLE [Nashville Housing Data for Data Cleaning]
Add OwnerSplitState NVARCHAR(255);

Update [Nashville Housing Data for Data Cleaning]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.' ), 1)

Select *
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), count(SoldAsVacant)
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant
 , CASE When SoldAsVacant = 'Y' THEN 'Yes'
        When SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

UPDATE [Nashville Housing Data for Data Cleaning]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
        When SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
        END



--Remove Duplicates
WITH RowNumCTE as(
SELECT *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                    UniqueID
                    ) row_num
   


From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]
)
DELETE
From RowNumCTE
where row_num > 1 


-- Delete unused columns

Select *
From portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]

Alter TABLE portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter TABLE portfolioHousing.dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate

