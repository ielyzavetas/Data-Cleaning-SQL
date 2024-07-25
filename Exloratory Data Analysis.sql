-- Exloratory Data Analysis 

-- Here I am jsut going to explore the data and find trends or patterns.

SELECT * 
FROM layoffs_staging2;

-- Which companies had 100 percent layoff
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Industries with the most Total Layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Countries with the most Total Layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Years with the most Total Layoffs
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Months and years with the most Total Layoffs
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

-- Companies with the most Layoffs per year

WITH Company_Year (company, years, total_laid_off) AS 
( 
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2 
GROUP BY company, YEAR(`date`) 
) 
SELECT *,  
DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking 
FROM Company_Year 
WHERE years IS NOT NULL 
ORDER BY Ranking ASC;

