SELECT [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
FROM [PorfolioProject].[dbo].[Nashville Housing]


  --
 
 SELECT *
  FROM PorfolioProject..[Nashville Housing]

  -- Standardize Date Format 

  SELECT SaleDate, CONVERT(Date,SaleDate)
  FROM PorfolioProject..[Nashville Housing];

  
  Update [Nashville Housing]
  SET SaleDate = CONVERT(Date, SaleDate) 


  ALTER TABLE [Nashville Housing]
  ADD SaleDateConvert Date;

  
 Update [Nashville Housing]
  SET SaleDateConvert = CONVERT(Date, SaleDate) 



  -- Populate Property Address data

  SELECT PropertyAddress
  FROM PorfolioProject..[Nashville Housing];

  SELECT *
  FROM PorfolioProject..[Nashville Housing]
  WHERE PropertyAddress IS NULL;


  SELECT *
  FROM PorfolioProject..[Nashville Housing]
  --WHERE PropertyAddress IS NULL;
  ORDER BY ParcelID;


  SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
  FROM PorfolioProject..[Nashville Housing] AS a
  JOIN PorfolioProject..[Nashville Housing] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--Now Blank
--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 -- FROM PorfolioProject..[Nashville Housing] AS a
 -- JOIN PorfolioProject..[Nashville Housing] AS b
	--ON a.ParcelID = b.ParcelID
	--AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PorfolioProject..[Nashville Housing] AS a
  JOIN PorfolioProject..[Nashville Housing] AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;


--Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PorfolioProject..[Nashville Housing];

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM PorfolioProject..[Nashville Housing];


ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [Nashville Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



SELECT OwnerAddress 
FROM PorfolioProject..[Nashville Housing];

--Looks for '.'
--SELECT PARSENAME(OwnerAddress, 1)
--FROM PorfolioProject..[Nashville Housing];


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PorfolioProject..[Nashville Housing];



ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--- Changeing "Sold as Vacant" field

SELECT Distinct(SoldASVacant)
From PorfolioProject..[Nashville Housing];


ALTER TABLE [Nashville Housing]
ALTER column SoldAsVacant varchar(5)


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = '0' THEN 'No'
	 WHEN SoldAsVacant = '1' THEN 'Yes'
	 ELSE SoldAsVacant
	 END
From PorfolioProject..[Nashville Housing];


UPDATE [Nashville Housing] 
SET SoldAsVacant = CASE WHEN SoldAsVacant = '0' THEN 'No'
	 WHEN SoldAsVacant = '1' THEN 'Yes'
	 ELSE SoldAsVacant
	 END


---- Remove Duplicates

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
			
FROM [Nashville Housing]
ORDER BY ParcelID;



WITH RowNumCTE AS(
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
			
FROM [Nashville Housing]
)
SELECT *
FROM RowNumCTE;


-- Now Blank
--WITH RowNumCTE AS(
--SELECT *,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				 PropertyAddress,
--				 SalePrice,
--				 SaleDate,
--				 LegalReference
--				 ORDER BY
--					UniqueID
--					) row_num
--			
--FROM [Nashville Housing]
--)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress;


WITH RowNumCTE AS(
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
			
FROM [Nashville Housing]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


---Delete Unused Columns

SELECT *
  FROM PorfolioProject..[Nashville Housing]


ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate



----------


SELECT [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
      ,[SaleDateConvert]
      ,[PropertySplitAddress]
      ,[PropertySplitCity]
      ,[OwnerSplitAddress]
      ,[OwnerSplitCity]
      ,[OwnerSplitState]
  FROM [PorfolioProject].[dbo].[Nashville Housing]
