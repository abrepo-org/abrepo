// Run this example by adding <%= javascript_pack_tag 'hello_react' %> to the head of your layout file,
// like app/views/layouts/application.html.erb. All it does is render <div>Hello React</div> at the bottom
// of the page.

import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import App from './App.jsx';


document.addEventListener('DOMContentLoaded', () => {

    const $app = document.getElementById('diffApp');

    ReactDOM.render(
        <App name="ReactoPresto" data={window.abrepo} />,
        //$app
        $app.appendChild(document.createElement('div'))
    );


});
