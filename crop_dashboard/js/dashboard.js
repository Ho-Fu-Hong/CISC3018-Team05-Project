// /var/www/html/crop_dashboard/js/dashboard.js

const API_PREDICT = 'php/predict_api.php';
const API_DATA = 'php/data_api.php';
const REFRESH_INTERVAL = 60000; // 60 seconds (Auto-refresh removed, but keep constant)

let fullDataset = []; // Stores the 45706 records from data_all_records_new.json
let comprehensiveChart = null; // Chart instance reference

// --- Data Fetching ---

/**
 * Fetches data from the PHP API.
 * @param {string} dataType 
 * @returns {Promise<Array<Object>>}
 */
async function fetchData(dataType) {
    const url = `${API_DATA}?type=${dataType}`;
    console.log('Fetching from URL:', url);

    try {
        const response = await fetch(url);
        console.log('Response status:', response.status);
        if (!response.ok) {
            const errorBody = await response.text();
            console.error(`HTTP error! status: ${response.status}`, errorBody);
            document.getElementById('prediction-result').innerHTML = 
                `Error loading data: ${response.status}`;
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        const data = await response.json();
        console.log('Data loaded successfully, length:', data.length); 
        return data;
    } catch (error) {
        console.error(`Error fetching ${dataType} data:`, error);
        return [];
    }
}

// --- Initialization and UI Population ---

/**
 * Loads the complete dataset, populates prediction/filter dropdowns.
 */
function initDataExploration(data) {
    fullDataset = data; 
    
    // --- Extract Unique Values ---
    const countries = [...new Set(data.map(item => item.Country))].sort();
    const crops = [...new Set(data.map(item => item.Crop))].sort();



    // --- Populate Dropdowns ---
    
    // 1. Prediction Dropdowns 
    populateDropdown('select-country', countries, false);
    populateDropdown('select-crop', crops, false);

    // 2. Filter Dropdowns 
    populateDropdown('filter-country', countries, true);
    populateDropdown('filter-crop', crops, true); 

    // Initial chart render
    filterAndRender(); 
}

/**
 * Fills an HTML select element with options.
 * @param {string} elementId - ID of the select element.
 * @param {Array<string>} options - Array of string options.
 * @param {boolean} includeAll - Whether to include an initial "All" option for filters.
 */
function populateDropdown(elementId, options, includeAll) {
    const selectElement = document.getElementById(elementId);
    if (!selectElement) return; 

    selectElement.innerHTML = '';
    
    if (includeAll) {

        selectElement.innerHTML = '<option value="">All Countries</option>'; 
    } else {

        selectElement.innerHTML = '<option value="">Select an option...</option>'; 
    }
    
    options.forEach(option => {
        const opt = document.createElement('option');
        opt.value = option;
        opt.textContent = option.toUpperCase();
        selectElement.appendChild(opt);
    });
}

// --- Data Filtering and Chart Rendering ---

/**
 * Filters data based on user selection and re-renders the chart.
 */
function filterAndRender() {

    const countryFilter = document.getElementById('filter-country').value; 
    const cropFilter = document.getElementById('filter-crop').value;
    const chartType = document.getElementById('chart-type').value;
    
    let filteredData = fullDataset;
    
    if (countryFilter) {
        filteredData = filteredData.filter(item => item.Country === countryFilter);
    }
    
    if (cropFilter) {
        filteredData = filteredData.filter(item => item.Crop === cropFilter);
    }

    renderComprehensiveChart(filteredData, chartType, countryFilter, cropFilter);
}


document.addEventListener('DOMContentLoaded', () => {

    document.getElementById('filter-country')?.addEventListener('change', filterAndRender);
    document.getElementById('filter-crop')?.addEventListener('change', filterAndRender);
    document.getElementById('chart-type')?.addEventListener('change', filterAndRender);
});

/**
 * Renders the primary chart.
 * @param {Array<Object>} data
 * @param {string} chartType
 * @param {string} countryFilter
 * @param {string} cropFilter
 */
function renderComprehensiveChart(data, chartType, countryFilter, cropFilter) {


    const groupedData = data.reduce((acc, curr) => {
        const year = curr.Year;
        if (!acc[year]) {
            acc[year] = [];
        }
        acc[year].push(curr.Yield);
        return acc;
    }, {});
    
    const years = Object.keys(groupedData).sort();
    const averageYields = years.map(year => {
        const yields = groupedData[year];
        return yields.reduce((a, b) => a + b, 0) / yields.length;
    });

    const ctx = document.getElementById('comprehensive-chart').getContext('2d');
    if (comprehensiveChart) {
        comprehensiveChart.destroy();
    }

    comprehensiveChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: years,
            datasets: [{
                label: 'Average Yield (hg/ha)',
                data: averageYields,
                borderColor: 'rgb(54, 162, 235)',
                backgroundColor: 'rgba(54, 162, 235, 0.2)',
                tension: 0.3,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: `Average Yield vs Year for ${countryFilter || 'All'} - ${cropFilter || 'All'}`
                }
            },
            scales: {
                y: {
                    title: {
                        display: true,
                        text: 'Average Yield (hg/ha)'
                    }
                }
            }
        }
    });
}


// --- Prediction Logic ---

async function getPrediction(event) {
    event.preventDefault(); 

 
    const year = document.getElementById('input-year').value;
    const rainfall = document.getElementById('input-rainfall').value;
    const pesticides = document.getElementById('input-pesticides').value;
    const temp = document.getElementById('input-temp').value;
    const country = document.getElementById('select-country').value;
    const crop = document.getElementById('select-crop').value;

    const resultDiv = document.getElementById('prediction-result');
    const predictedValueSpan = document.getElementById('predicted-value');
    
    // Simple form validation check
    if (!document.getElementById('prediction-form').checkValidity()) {
        alert("Please fill out all required fields.");
        return;
    }

    // Construct API URL for PHP script
    const apiUrl = `${API_PREDICT}?year=${year}&rainfall=${rainfall}&pesticides=${pesticides}&temp=${temp}&country=${country}&crop=${crop}`;

    predictedValueSpan.textContent = 'Calculating...';
    resultDiv.classList.remove('alert-danger', 'alert-success');
    resultDiv.classList.add('alert-secondary');
    
    try {
        const response = await fetch(apiUrl);
        const data = await response.json();

        if (data.error) {
            predictedValueSpan.textContent = `Error: ${data.error}`;
            resultDiv.classList.remove('alert-secondary');
            resultDiv.classList.add('alert-danger');
            console.error('Prediction API Error:', data.details || data.error);
        } else {
            predictedValueSpan.textContent = data.predicted_yield.toLocaleString(undefined, { maximumFractionDigits: 2 });
            resultDiv.classList.remove('alert-secondary', 'alert-danger');
            resultDiv.classList.add('alert-success');
        }
    } catch (error) {
        predictedValueSpan.textContent = 'Failed to connect to the prediction service.';
        resultDiv.classList.remove('alert-secondary');
        resultDiv.classList.add('alert-danger');
        console.error('Fetch Error:', error);
    }
}


document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('prediction-form')?.addEventListener('submit', getPrediction);
});

// --- Main Dashboard Loading ---

async function loadDashboard() {
    console.log("Loading dashboard data...");
    
    const allNewData = await fetchData('all_new');
    console.log("Fetched data:", allNewData);

    if (allNewData.length > 0) {
        initDataExploration(allNewData); // Initialize UI with the new data
    } else {
        console.error("Failed to load full dataset. Cannot initialize UI.");

        document.getElementById('select-country').innerHTML = 
            '<option value="">Data load failed</option>';
        document.getElementById('select-crop').innerHTML = 
            '<option value="">Data load failed</option>';
        
        document.getElementById('filter-country').innerHTML = 
            '<option value="All">Data load failed</option>';
        document.getElementById('filter-crop').innerHTML = 
            '<option value="All">Data load failed</option>';
    }

    
}

// Start loading
loadDashboard();
