import React from 'react';
import ReactDOM from 'react-dom';

export default class Img extends React.Component {

    constructor(props) {
        super(props);
        console.log("Img", this.props.renderable.screenshot);

    }

    render() {

        const style = {
            outline: '1px solid #000'
        };

        return(
            <img src={this.props.renderable.screenshot}
                 style={style}
                 onClick={() => this.props.imgClickHandler()}
              />
        );
    }
}
