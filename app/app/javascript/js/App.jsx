import React from 'react';
import ReactDOM from 'react-dom';
import Variation from './variations';

export default class App extends React.Component {

    constructor(props) {
        super(props);
    }

    render() {
        //console.log("crawlID", this.state.data.renderable.crawlId);

        return  <Variation {...this.props} />

    }
}
