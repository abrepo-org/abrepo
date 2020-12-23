import React from 'react';
import ReactDOM from 'react-dom';

export default class App extends React.Component {

    constructor(props) {
        super(props);
        this.state = {
            data: props.data
        };
    }

    render() {
        console.log("crawlID", this.state.data.renderable.crawlId);

        return (
            <div>Hi</div>
        );
    }
}
