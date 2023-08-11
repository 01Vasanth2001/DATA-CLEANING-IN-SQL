---------------------------------------DATA CLEANING IN SQL----------------------------------------
--Using a housing dataset to work out the following queries to clean the data 


---SHOWING THE DATA-----

------------------------------------------------------------------------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject..Housing

-----The saledate consists of unwanted data (00:00:00) -- to remove that,....

ALTER TABLE housing
ADD saledateconverted date

UPDATE Housing
SET saledateconverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------------------

----POPULATE PROPERTY ADDRESS DATA----------------

SELECT *
FROM PortfolioProject..Housing
WHERE PropertyAddress is Null
ORDER BY ParcelID

-----------------------------------------------------------------------------------------------------------------------------------

--ON research ,we can see that some ParcelID's have some Property Address everywhere , using that, we can fill all the NULL values.

--Join the table with the same table . And show 4 columns- 
--The first table containing ParcelID with Null Values;
--The Second Table containing the same corresponding ParceLID's with filled property address..

SELECT a.ParcelID,a.propertyaddress,b.parcelID,b.PropertyAddress
FROM PortfolioProject..Housing a
JOIN  PortfolioProject..Housing b
      ON a.ParcelID=b.ParcelID
	  AND a.[UniqueID ]=b.[UniqueID ]
WHERE a.PropertyAddress is Null

-------------------------------------------------------------------------------------------------------------------------------------------------------------

---To add a column which results in matching the null values 
SELECT a.ParcelID,a.propertyaddress,b.parcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.propertyaddress)
FROM PortfolioProject..Housing a
JOIN  PortfolioProject..Housing b
      ON a.ParcelID=b.ParcelID
	  AND a.[UniqueID ]=b.[UniqueID ]
WHERE a.PropertyAddress is Null

-----------------------------------------------------------------------------------------------------------------------------------

--THEN UPDATE--

UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress,b.propertyaddress)
FROM PortfolioProject..Housing a
JOIN  PortfolioProject..Housing b
      ON a.ParcelID=b.ParcelID
	  AND a.[UniqueID ]=b.[UniqueID ]
WHERE a.PropertyAddress is Null

----Check Once By Running The Second Previous Code

--------------------------------------------------------------------------------------------------------------------------------------

-----BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS-(address,city,state)

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address
FROM PortfolioProject.dbo.Housing

---TO show both first part and the second part at the same time

SELECT 
SUBSTRING (PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.Housing

--Now Add the tables into the main table

ALTER table housing
ADD PropertySplitAddress nvarchar (255)

UPDATE Housing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

ALTER table housing
ADD PropertySplitCity nvarchar (255)

UPDATE Housing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

---You Will See The Results At The End of The Table

-----------------------------------------------------------------------------------------------------------------------------------------------

---EASIER WAY TO DO THE ABOVE SPLITTING METHOD(PARSENAME)

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3), 
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
FROM portfolioproject.dbo.Housing

--UPDATE 
ALTER table housing
ADD OwnerAddress1 nvarchar (255)

UPDATE Housing
SET OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER table housing
ADD OwnerCity nvarchar (255)

UPDATE Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)


ALTER table housing
ADD OwnerState nvarchar (255)

UPDATE Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


------------------------------------------------------------------------------------------------------------------------------


--IN SoldasVacant field there are both y's and yes's ; n's and no's

SELECT DISTINCT(soldasvacant),COUNT(soldasvacant) 
FROM PortfolioProject..Housing
GROUP BY  soldasvacant
ORDER BY 2

--to change all y's to yes and n's to No's ;.........

SELECT SoldasVacant,
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldasVacant
	 END as SoldasVacantChanged
FROM portfolioproject.dbo.housing

--UPDATE-----

UPDATE Housing
SET SoldAsVacant = 
CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
     WHEN SoldasVacant = 'N' THEN 'No'
	 ELSE SoldasVacant
	 END 

	 ------------------------------------------------------------------------------------------------------------------------------------

----REMOVING DUPLICATES


--Here we use partition by and order by to select the Important Columns
--Then ssign the row numbers into consecutive row numbers
--Then delete rows whose row number is > 1

--USE CTE


WITH RowNumCTE AS (
SELECT* , 
ROW_NUMBER () OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
			    SalePrice,
			    SaleDate,
			    LegalReference
   ORDER BY 
   UniqueID ) row_num
FROM PortfolioProject.dbo.Housing
ORDER BY PropertyAddress
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLUMNS

ALTER Table portfolioproject.dbo.Housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate

ALTER Table portfolioproject.dbo.Housing
DROP COLUMN  PropertySplitAddress,PropertySplitCity

------------------------------------------------------------THE END---------------------------------------------------------------------