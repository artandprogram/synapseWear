var chart;

function graph(type, labels, data, colorValues) {
	var chartColors = {
        white: 'rgb(255, 255, 255)',
		red: 'rgb(220, 32, 103)',
		orange: 'rgb(254, 142, 61)',
		yellow: 'rgb(227, 241, 59)',
		green: 'rgb(0, 229, 207)',
		blue: 'rgb(55, 118, 255)',
		purple: 'rgb(137, 73, 246)',
		grey: 'rgb(201, 203, 207)'
	};
	var color = Chart.helpers.color;

    var datasets = [];
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

        datasets.push({
                      backgroundColor: chartColor,
                      //backgroundColor: color(chartColor).alpha(0.5).rgbString(),
                      borderColor: chartColor,
                      borderWidth: 1,
                      pointRadius: 1,
                      fill: false,
                      yAxisID: 'y-axis-' + i,
                      data: data[i]
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
			responsive: true,
			legend: {
				display: false,
			},
			title: {
				display: false,
			},
            animation: false,
            scales: {
                yAxes: [
                {
                    id: 'y-axis-0',
                    type: 'linear',
                    position: 'right',
                    display: false
                },
                {
                    id: 'y-axis-1',
                    type: 'linear',
                    position: 'right',
                    display: false
                },
                {
                    id: 'y-axis-2',
                    type: 'linear',
                    position: 'right',
                    display: false
                },
                {
                    id: 'y-axis-3',
                    type: 'linear',
                    position: 'right',
                    display: false
                },
                {
                    id: 'y-axis-4',
                    type: 'linear',
                    position: 'right',
                    display: false
                },
                {
                    id: 'y-axis-5',
                    type: 'linear',
                    position: 'right',
                    display: false
                }
                ]
            }
		}
	};

    chart = new Chart(ctx, chartData);
}

function updateGraph(labels, data) {
    if (chart != null) {
        chart.data.labels = labels;
        for (let i=0; i<data.length; i++) {
            if (i < chart.data.datasets.length) {
                chart.data.datasets[i].data = data[i];
            }
        }
        chart.update();
    }
}
