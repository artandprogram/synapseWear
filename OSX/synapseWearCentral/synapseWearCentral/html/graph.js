var chart;

function graph(type, labels, data, hiddens, colorValues, scales) {
	var chartColors = {
        white: 'rgb(255, 255, 255)',
		red: 'rgb(220, 32, 103)',
        orange: 'rgb(254, 142, 61)',
		yellow: 'rgb(227, 241, 59)',
		green: 'rgb(0, 229, 207)',
		blue: 'rgb(55, 118, 255)',
		purple: 'rgb(137, 73, 246)',
        brown: 'rgb(139, 69, 19)',
        pink: 'rgb(255, 192, 203)',
		grey: 'rgb(201, 203, 207)'
	};
	var color = Chart.helpers.color;

    var datasets = [];
    var yAxes = [];
    for (let i=0; i<data.length; i++) {
        var colorValue = colorValues[i % data.length];
        var chartColor = chartColors.grey;
        if (colorValue == "white") {
            chartColor = chartColors.white;
        }
        else if (colorValue == "red") {
            chartColor = chartColors.red;
        }
        else if (colorValue == "orange") {
            chartColor = chartColors.orange;
        }
        else if (colorValue == "yellow") {
            chartColor = chartColors.yellow;
        }
        else if (colorValue == "green") {
            chartColor = chartColors.green;
        }
        else if (colorValue == "blue") {
            chartColor = chartColors.blue;
        }
        else if (colorValue == "purple") {
            chartColor = chartColors.purple;
        }
        else if (colorValue == "brown") {
            chartColor = chartColors.brown;
        }
        else if (colorValue == "pink") {
            chartColor = chartColors.pink;
        }

        var yAxisID = 'y-axis-' + i;
        var hidden = false;
        if (i < hiddens.length) {
            hidden = hiddens[i];
        }
        datasets.push({
                      backgroundColor: chartColor,
                      //backgroundColor: color(chartColor).alpha(0.5).rgbString(),
                      borderColor: chartColor,
                      borderWidth: 1,
                      pointRadius: 1,
                      fill: false,
                      yAxisID: yAxisID,
                      hidden: hidden,
                      data: data[i]
                      });

        var ticks = {};
        if (i < scales.length) {
            ticks = scales[i];
        }
        yAxes.push({
            id: yAxisID,
            type: 'linear',
            position: 'right',
            ticks: ticks,
            display: false
        });
    }

	var ctx = document.getElementById('graph').getContext('2d');
	var chartData = {
		type: type,
		data: {
			labels: labels,
			datasets: datasets
		},
		options: {
            layout: {
                padding: {
                    left: 0,
                    right: 0,
                    top: 10,
                    bottom: 0
                }
            },
			responsive: true,
			legend: {
				display: false,
			},
			title: {
				display: false,
			},
            animation: false,
            scales: {
                yAxes: yAxes
            }
		}
	};

    chart = new Chart(ctx, chartData);
}

function updateGraph(labels, data, scales) {
    if (chart != null) {
        chart.data.labels = labels;
        for (let i=0; i<data.length; i++) {
            if (i < chart.data.datasets.length) {
                chart.data.datasets[i].data = data[i];
            }
        }
        for (let i=0; i<scales.length; i++) {
            if (i < chart.options.scales.yAxes.length) {
                chart.options.scales.yAxes[i].ticks = scales[i];
            }
        }
        chart.update();
    }
}

function setGraphHiddens(hiddens) {
    if (chart != null) {
        for (let i=0; i<hiddens.length; i++) {
            if (i < chart.data.datasets.length) {
                chart.data.datasets[i].hidden = hiddens[i];
            }
        }
        chart.update();
    }
}
