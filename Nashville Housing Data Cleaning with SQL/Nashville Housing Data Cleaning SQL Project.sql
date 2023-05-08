--Creating the table for our data
CREATE TABLE IF NOT EXISTS Nashville_Housing(
UniqueID NUMERIC UNIQUE NOT NULL,
ParcelID VARCHAR(30) NOT NULL,
LandUse CHAR(200),
PropertyAddress VARCHAR(250),
SaleDate DATE,
SalePrice NUMERIC,
LegalReference VARCHAR(250),
SoldAsVacant CHAR(3),
OwnerName CHAR(250),
OwnerAddress VARCHAR(250),
Acreage NUMERIC,
TaxDistrict CHAR(200),
LandValue NUMERIC,
BuildingValue NUMERIC,
TotalValue NUMERIC,
YearBuilt NUMERIC,
Bedrooms NUMERIC,
FullBath NUMERIC,
HalfBath NUMERIC
);

--Taking a look at our data
SELECT *
FROM nashville_housing
;

--Using the parcelid column to locate the missing property addresses in the data, and populating null values in the propertyaddress column with those addresses.
SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing as a
JOIN nashville_housing as b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

--Populate Property Address Data
Update nashville_housing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashville_housing as a
JOIN nashville_housing as b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS NULL;

--Separating Address
SELECT
SUBSTRING(propertyaddress, 1, strpos(propertyaddress,',') -1) AS Address
, SUBSTRING(propertyaddress, strpos(propertyaddress,',') +1, Length(propertyaddress)) AS Address
FROM nashville_housing;

--Table Edits
ALTER TABLE nashville_housing
Add PropertySplitAddress varchar(255);

--Table Updates
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, strpos(propertyaddress,',') -1);

--More Table Edits
ALTER TABLE nashville_housing
Add PropertySplitCity varchar(255);

--More Table Updates
UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(propertyaddress, strpos(propertyaddress,',') +1, Length(propertyaddress));

--Table Edits
ALTER TABLE nashville_housing
Add PropertySplitAddress varchar(255);

--Table Updates
UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, strpos(propertyaddress,',') -1);

--Splitting Owner Address
SELECT SPLIT_PART(OwnerAddress, ',', 1)
,SPLIT_PART(OwnerAddress, ',', 2)
,SPLIT_PART(OwnerAddress, ',', 3)
FROM nashville_housing;

--Table Edits
ALTER TABLE nashville_housing
Add OwnerSplitAddress varchar(255);

--Table Updates
UPDATE nashville_housing
SET OwnerSplitAddress = SPLIT_PART(OwnerAddress, ',', 1);

--More Table Edits
ALTER TABLE nashville_housing
Add OwnerSplitCity varchar(255);

--More Table Updates
UPDATE nashville_housing
SET OwnerSplitCity = SPLIT_PART(OwnerAddress, ',', 2);

--Even More Table Edits
ALTER TABLE nashville_housing
Add OwnerSplitState Varchar(5);

--Even More Table Updates
UPDATE nashville_housing
SET OwnerSplitState = SPLIT_PART(OwnerAddress, ',', 3);

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
Order by 2;

--Conversion
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM nashville_housing;

--Table Updates
UPDATE nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END;

--Looking at our data
SELECT *
FROM nashville_housing;

--Find Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			ORDER BY
				uniqueid) AS row_num
FROM nashville_housing
--ORDER BY parcelid
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY parcelid,
            propertyaddress,
            saleprice,
            saledate,
            legalreference
            ORDER BY uniqueid
        ) AS row_num
    FROM nashville_housing
)
DELETE FROM nashville_housing
WHERE uniqueid IN (
    SELECT uniqueid
    FROM RowNumCTE
    WHERE row_num > 1
);

--Checking to see if any duplicates remain
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			ORDER BY
				uniqueid) AS row_num
FROM nashville_housing
--ORDER BY parcelid
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1;

--Removing Unused Columns
ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

--Looking at our data again
SELECT *
FROM nashville_housing;
