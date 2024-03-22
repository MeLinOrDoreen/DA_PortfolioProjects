/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM PortfolioProjects..NashvilleHousing;

----------------------------------------------------------------------------------------------------
-- Standardize Data Format
----------------------------------------------------------------------------------------------------

-- SELECT SaleDate, CONVERT(Date, SaleDate)
-- FROM PortfolioProjects..NashvilleHousing;

SELECT SaleDate --, CONVERT(Date, SaleDate)
FROM PortfolioProjects..NashvilleHousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate);

-- ALTER TABLE NashvilleHousing
-- ADD SaleDateConverted DATE

-- UPDATE NashvilleHousing
-- SET SaleDateConverted = CONVERT(DATE, SaleDate);


----------------------------------------------------------------------------------------------------
-- Populate Property Address data using ParcelID
----------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProjects..NashvilleHousing
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) -- ISNULL(a.PropertyAddress, "No Address")
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL; 


----------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
----------------------------------------------------------------------------------------------------

-- PropertyAddress
SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(50);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(50);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT PropertySplitAddress, PropertySplitCity
FROM PortfolioProjects..NashvilleHousing;

-- OwnerAddress

SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProjects..NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(50);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE NashvilleHousing
ADD OwnersplitCity NVARCHAR(50);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(50);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM PortfolioProjects..NashvilleHousing

-- ALTER TABLE NashvilleHousing
-- DROP COLUMN OwnerSpiltState;



----------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
----------------------------------------------------------------------------------------------------

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END;

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;



----------------------------------------------------------------------------------------------------
-- Remove Duplicates
----------------------------------------------------------------------------------------------------
WITH RowNumCTE
AS(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) row_num
FROM PortfolioProjects..NashvilleHousing
)
DELETE 
--SELECT *
FROM RowNumCTE
WHERE row_num > 1;

WITH RowNumCTE
AS(
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
        ORDER BY UniqueID
    ) row_num
FROM PortfolioProjects..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



SELECT *
FROM PortfolioProjects..NashvilleHousing;


----------------------------------------------------------------------------------------------------
-- Delete unused columns
---------------------------------------------------------------------------------------------------

-- Create a View is better
-- CREATE VIEW view_name AS
-- SELECT col_1, col_2, ...
-- FROM table_name
-- WHERE conditions;


ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

SELECT *
FROM PortfolioProjects..NashvilleHousing;


-- /* Get the data into a temp table */
-- SELECT * INTO #TempTable
-- FROM PortfolioProjects..NashvilleHousing
-- /* Drop the columns that are not needed */
-- ALTER TABLE #TempTable
-- DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
-- /* Get results and drop temp table */
-- SELECT * FROM #TempTable

-- DROP TABLE #TempTable
