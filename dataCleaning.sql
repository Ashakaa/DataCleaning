
select * 
from portfolioProject..NashvilleHousing

--Standardized date format 

Select SaleDateConverted, convert(date,SaleDate)
from portfolioProject..NashvilleHousing

update NashvilleHousing
set saledate = convert(date,SaleDate)

Alter table Nashvillehousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)

-- populate property address data 

Select *
from portfolioProject..NashvilleHousing
--where PropertyAddress is Null
order by ParcelID
-- same parcelID = same address

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioProject..NashvilleHousing a
join portfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from portfolioProject..NashvilleHousing a
join portfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where  a.PropertyAddress is null

--Breaking out Address into individual Columns (address, city, state.) 

select propertyaddress
from portfolioProject..NashvilleHousing

-- the delimiter is a comma 

select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)) as Address,
CHARINDEX(',', propertyAddress)
from portfolioProject..NashvilleHousing


select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1) as Address,
SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress)+1, len(PropertyAddress)) as Address
from portfolioProject..NashvilleHousing

Alter table portfolioproject..NashvilleHousing
add PropertySplitAddress Nvarchar(255)

update portfolioproject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyAddress)-1)

Alter table portfolioproject..NashvilleHousing
add PropertySplitCity nvarchar(255);

update portfolioproject..NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyAddress, CHARINDEX(',', propertyAddress)+1, len(PropertyAddress))

--at the very end we can see the two new values 
select *
from portfolioProject..NashvilleHousing



select OwnerAddress
from portfolioProject..NashvilleHousing

-- another way to splitting the data from one set into more than one set is to use parse name instead of substrings


select 
PARSENAME(replace(OwnerAddress, ',', '.') ,3), 
PARSENAME(replace(OwnerAddress, ',', '.') ,2),  
PARSENAME(replace(OwnerAddress, ',', '.') ,1) 
from portfolioProject..NashvilleHousing


Alter table portfolioproject..NashvilleHousing
add OwnerSplitAddress Nvarchar(255)

update portfolioproject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') ,3)

Alter table portfolioproject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update portfolioproject..NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') ,2)

Alter table portfolioproject..NashvilleHousing
add OwnerSplitState Nvarchar(255)

update portfolioproject..NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') ,1) 

select *
from portfolioProject..NashvilleHousing

-- change y and n to yes and noo in "sold as vacant field"

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from portfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2 

select SoldAsVacant
	, case when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from portfolioProject..NashvilleHousing

update portfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- remove duplicates 

select *, 
	Row_number() over ( 
	partition by ParcelID,
		propertyaddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by uniqueID
		) Row_num
from portfolioProject..NashvilleHousing
Order by ParcelID


select * 
from portfolioProject..NashvilleHousing


With RowNumCTE AS(
select *, 
	Row_number() over ( 
	partition by ParcelID,
		propertyaddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by uniqueID
		) Row_num
from portfolioProject..NashvilleHousing
--Order by ParcelID
)
delete
from RowNumCTE
where ROW_NUM > 1 



With RowNumCTE AS(
select *, 
	Row_number() over ( 
	partition by ParcelID,
		propertyaddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by uniqueID
		) Row_num
from portfolioProject..NashvilleHousing
--Order by ParcelID
)
select *
from RowNumCTE
where ROW_NUM > 1 
ORDER BY Propertyaddress



--delete unused columns 

select *
From portfolioProject..NashvilleHousing

alter table portfolioProject..NashvilleHousing
drop column owneraddress, taxdistrict, propertyaddress


alter table portfolioProject..NashvilleHousing
drop column Saledate


